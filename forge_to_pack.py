#!/usr/bin/env python3
"""
forge_to_pack.py

ai assisted

Convert a CurseForge modpack zip into a "generic pack" zip that
itzg/docker-minecraft-server can consume via the GENERIC_PACK cfg

Why this is needed
-------------------
itzg/docker-minecraft-server has two different ways of dealing with CurseForge
content:

  1. MODPACK_PLATFORM=AUTO_CURSEFORGE - the container itself talks to the
     CurseForge API at startup, resolves the modpack, and also installs the mod
     loader (Forge/Fabric/etc) that the modpack declares.
  2. GENERIC_PACK=<zip> - the container just unzips the given archive directly
     on top of /data. No CurseForge API calls happen for this path, and no mod
     loader installation happens either - GENERIC_PACK assumes the zip already
     contains real files (jars, configs, etc), not CurseForge manifest
     references.

  See: https://github.com/itzg/docker-minecraft-server/discussions/4026

When you need a *custom* mod loader install (like a CleanroomMC
FORGE_INSTALLER_URL) the AUTO_CURSEFORGE flow can't be used, because
AUTO_CURSEFORGE always wants to own the loader install step too. The documented
workaround (see the discussion above) is: use TYPE=FORGE + FORGE_INSTALLER_URL
for the custom loader, and pair it with GENERIC_PACK pointing at an
already-resolved zip.

This script builds that already-resolved zip.

Download resolution order for each mod
--------------------------------------
  1. downloadUrl from the CurseForge API (null if the author disabled
     third-party downloads)
  2. CurseForge CDN URL built from fileId + fileName
     (edge.forgecdn.net, then mediafilez.forgecdn.net)

If the API provides a SHA-1 for the file, each download is verified against it
and rejected on mismatch.

Requires
--------
  pip install requests

A CurseForge API key, read from a `.env` file (CF_API_KEY=... - the same
variable name/format used by itzg/docker-minecraft-server) sitting next to this
script by default, or pointed to with --env-file.

Usage
-----
  ./forge_to_pack.py profile.zip
  ./forge_to_pack.py profile.zip --exclude 244447
  ./forge_to_pack.py profile.zip --exclude 244447 987654 --jobs 8
  ./forge_to_pack.py profile.zip --output ./server-pack/pack.zip
"""

import argparse
import concurrent.futures
import hashlib
import json
import os
import shutil
import sys
import tempfile
import zipfile
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from urllib.parse import quote

try:
    import requests
except ImportError:
    print(
        "error: the 'requests' package is required (pip install requests --break-system-packages)",
        file=sys.stderr,
    )
    sys.exit(1)

CF_API_BASE = "https://api.curseforge.com"
CDN_HOSTS = ("edge.forgecdn.net", "mediafilez.forgecdn.net")

# Top-level files inside a CurseForge profile zip that this script
# deliberately does not carry into the generic pack.
IGNORED_ROOT_FILES = {"modlist.html", "manifest.json"}


def load_env_file(path: Path) -> dict:
    """Minimal .env parser: KEY=VALUE per line, '#' comments, optional quotes."""
    env = {}
    if not path.is_file():
        return env
    for raw_line in path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, _, value = line.partition("=")
        key = key.strip()
        value = value.strip()
        if len(value) >= 2 and value[0] == value[-1] and value[0] in ("'", '"'):
            value = value[1:-1]
        env[key] = value
    return env


def load_manifest(profile_zip: zipfile.ZipFile) -> dict:
    try:
        with profile_zip.open("manifest.json") as f:
            return json.load(f)
    except KeyError:
        print("error: manifest.json not found at the root of the profile zip", file=sys.stderr)
        sys.exit(1)


def fetch_file_infos(file_ids: List[int], api_key: str) -> Dict[int, dict]:
    """Batch-resolve fileIds -> CurseForge file info via POST /v1/mods/files.

    Returns a dict keyed by fileId. Missing entries mean the API had nothing
    for that id (deleted file, bad id, etc).
    """
    if not file_ids:
        return {}
    headers = {"x-api-key": api_key, "Accept": "application/json", "Content-Type": "application/json"}
    result: Dict[int, dict] = {}
    # The batch endpoint accepts a reasonably large list, but chunk defensively.
    chunk_size = 50
    for i in range(0, len(file_ids), chunk_size):
        chunk = file_ids[i : i + chunk_size]
        resp = requests.post(
            f"{CF_API_BASE}/v1/mods/files",
            headers=headers,
            json={"fileIds": chunk},
            timeout=30,
        )
        if resp.status_code != 200:
            print(
                f"warning: CurseForge API batch lookup failed ({resp.status_code}): {resp.text[:300]}",
                file=sys.stderr,
            )
            continue
        for entry in resp.json().get("data", []):
            result[entry["id"]] = entry
    return result


def candidate_urls(file_info: dict, file_id: int, filename: str) -> List[str]:
    """Ordered list of URLs to try for a file.

    downloadUrl is null when the author disabled third-party/API downloads,
    but the file usually still exists on the CDN at a path derived from the
    file ID: /files/<id // 1000>/<id % 1000>/<fileName> (not zero-padded).
    """
    urls: List[str] = []
    api_url = file_info.get("downloadUrl")
    if api_url:
        urls.append(api_url)
    quoted_name = quote(filename)
    for host in CDN_HOSTS:
        cdn = f"https://{host}/files/{file_id // 1000}/{file_id % 1000}/{quoted_name}"
        if cdn not in urls:
            urls.append(cdn)
    return urls


def expected_sha1(file_info: dict) -> Optional[str]:
    # CurseForge hash algo 1 = SHA1, 2 = MD5
    for h in file_info.get("hashes", []) or []:
        if h.get("algo") == 1:
            return h.get("value", "").lower()
    return None


def sha1_of(path: Path) -> str:
    h = hashlib.sha1()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 16), b""):
            h.update(chunk)
    return h.hexdigest()


def download_one(session: requests.Session, url: str, dest: Path) -> None:
    with session.get(url, stream=True, timeout=60) as resp:
        resp.raise_for_status()
        dest.parent.mkdir(parents=True, exist_ok=True)
        with open(dest, "wb") as f:
            for chunk in resp.iter_content(chunk_size=1 << 16):
                f.write(chunk)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("profile_zip", type=Path, help="Path to the CurseForge profile .zip")
    parser.add_argument(
        "--exclude",
        type=int,
        nargs="*",
        default=[],
        metavar="PROJECT_ID",
        help="CurseForge projectID(s) to exclude from the generated pack "
        "(e.g. client-only mods that break a dedicated server)",
    )
    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        default=None,
        help="Output pack zip path (default: <profile-name>-generic-pack.zip next to the input)",
    )
    parser.add_argument(
        "--env-file",
        type=Path,
        default=None,
        help="Path to the .env file containing CF_API_KEY (default: .env next to this script)",
    )
    parser.add_argument("--jobs", type=int, default=6, help="Parallel mod downloads (default: 6)")
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Exit non-zero if any mod failed to resolve/download (default: warn and continue)",
    )
    args = parser.parse_args()

    if not args.profile_zip.is_file():
        parser.error(f"profile zip not found: {args.profile_zip}")

    env_file = args.env_file or (Path(__file__).resolve().parent / ".env")
    env = load_env_file(env_file)
    api_key = env.get("CF_API_KEY") or os.environ.get("CF_API_KEY")
    if not api_key:
        parser.error(
            f"CF_API_KEY not found. Put it in {env_file} (CF_API_KEY=...) "
            "or export it as an environment variable."
        )

    exclude_set = set(args.exclude)

    with zipfile.ZipFile(args.profile_zip) as zf:
        manifest = load_manifest(zf)
        mc = manifest.get("minecraft", {})
        loaders = mc.get("modLoaders", [])
        primary_loader = next((l["id"] for l in loaders if l.get("primary")), (loaders[0]["id"] if loaders else "?"))
        print(f"pack name     : {manifest.get('name', '?')}")
        print(f"mc version    : {mc.get('version', '?')}")
        print(f"mod loader    : {primary_loader}")
        print(f"manifest files: {len(manifest.get('files', []))}")

        all_refs = manifest.get("files", [])
        included = [f for f in all_refs if f["projectID"] not in exclude_set]
        excluded = [f for f in all_refs if f["projectID"] in exclude_set]
        if excluded:
            print(f"excluding {len(excluded)} mod(s) by projectID: {sorted(exclude_set)}")

        with tempfile.TemporaryDirectory(prefix="forge_to_pack_") as tmpdir:
            work = Path(tmpdir)
            pack_root = work / "pack"
            mods_dir = pack_root / "mods"
            mods_dir.mkdir(parents=True, exist_ok=True)

            # Resolve + download mods.
            file_ids = [f["fileID"] for f in included]
            print(f"resolving {len(file_ids)} file(s) against the CurseForge API...")
            infos = fetch_file_infos(file_ids, api_key)

            failures = []
            session = requests.Session()

            def handle(ref) -> Tuple[str, int, int, str]:
                pid, fid = ref["projectID"], ref["fileID"]
                info = infos.get(fid)
                if info is None:
                    return ("no-info", pid, fid, f"{pid}-{fid}.jar (file ID not returned by CurseForge API)")

                filename = info.get("fileName") or f"{pid}-{fid}.jar"
                dest = mods_dir / filename
                want_sha1 = expected_sha1(info)
                errors: List[str] = []

                # API downloadUrl first, then CDN guesses.
                for url in candidate_urls(info, fid, filename):
                    try:
                        download_one(session, url, dest)
                        if want_sha1 and sha1_of(dest) != want_sha1:
                            dest.unlink(missing_ok=True)
                            errors.append(f"{url}: sha1 mismatch")
                            continue
                        source = "api" if url == info.get("downloadUrl") else "cdn"
                        return ("ok", pid, fid, f"{filename} [{source}]")
                    except Exception as exc:  # noqa: BLE001 - try next source
                        dest.unlink(missing_ok=True)
                        errors.append(f"{url}: {exc}")

                hint = "; ".join(errors) if errors else "no usable download source"
                return ("failed", pid, fid, f"{filename} ({hint})")

            with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as pool:
                for status, pid, fid, name in pool.map(handle, included):
                    if status == "ok":
                        print(f"  downloaded {name}  (project {pid}, file {fid})")
                    else:
                        failures.append((pid, fid, name))
                        print(f"  WARNING could not resolve/download project {pid} file {fid}: {name}", file=sys.stderr)

            # Apply overrides/ on top of the pack root (configs, scripts,
            # structures, resources, options.txt, and any locally-bundled
            # mods the pack author shipped directly).
            overrides_name = manifest.get("overrides", "overrides")
            for member in zf.namelist():
                if member == f"{overrides_name}/" or not member.startswith(f"{overrides_name}/"):
                    continue
                rel = member[len(overrides_name) + 1 :]
                if not rel:
                    continue
                target = pack_root / rel
                if member.endswith("/"):
                    target.mkdir(parents=True, exist_ok=True)
                    continue
                target.parent.mkdir(parents=True, exist_ok=True)
                with zf.open(member) as src, open(target, "wb") as dst:
                    shutil.copyfileobj(src, dst)

            # manifest.json / modlist.html are intentionally not copied -
            # they're CurseForge-app bookkeeping, not server content.

            # Zip it up.
            default_name = f"{args.profile_zip.stem}-generic-pack.zip"
            output_path = args.output or (args.profile_zip.parent / default_name)
            output_path.parent.mkdir(parents=True, exist_ok=True)
            if output_path.exists():
                output_path.unlink()

            with zipfile.ZipFile(output_path, "w", zipfile.ZIP_DEFLATED) as out_zf:
                for path in pack_root.rglob("*"):
                    if path.is_file():
                        out_zf.write(path, path.relative_to(pack_root))

    print()
    print(f"wrote {output_path}")
    print(f"  included mods : {len(included) - len(failures)}/{len(included)}")
    print(f"  excluded mods : {len(excluded)}")
    if failures:
        print(f"  FAILED mods   : {len(failures)} (see warnings above)")
        for pid, fid, name in failures:
            print(f"    - project {pid} file {fid}: {name}")
        if args.strict:
            return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())