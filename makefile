# exclude:
# - camouflage creepers (client side only and breaks server side)
# - cleanroom relauncher (explicitly client-side only, see compose.yml FORGE_INSTALLER_URL instead)
# - fugue (see compose.yml, version controlled by server not client since linked to cleanroom)
# - scalar legacy (same as previous)
# - distant horizons: https://github.com/itzg/docker-minecraft-server/discussions/4026#discussioncomment-18617629
start:
	(cd modpack-client && ./scripts/export_profile.py profile.zip)
	./forge_to_pack.py ./modpack-client/profile.zip --exclude 244447 1214490 1005815 1235372 508933 -o pack.zip && rm ./modpack-client/profile.zip
	docker compose up -d --remove-orphans

stop:
	docker compose down

enter:
	docker compose exec -i mc rcon-cli

backup:
	docker compose exec backups backup now

restore-backup:
	./scripts/restore-backup.sh

install-functions:
	./scripts/install-functions.sh
