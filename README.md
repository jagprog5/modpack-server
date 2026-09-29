# John's 1.12.2

This is a dockerized forge server for minecraft 1.12.2 (via [itzg/minecraft-server](https://hub.docker.com/r/itzg/minecraft-server/)). It pulls from [this mod pack](https://github.com/jagprog5/modpack-client).

## Install

```bash
git clone --recurse-submodules https://github.com/jagprog5/modpack-server
```

Create the env file:

```bash
cp env .env
```

Then, get a [curseforge api key](https://console.curseforge.com/) and put it in the `.env` file.

Consider installing server functions (see `install-functions` below).

## Commands

Thin wrapper around docker compose:

```bash
make start # start it

# all commands below should be invoked on a running server
make enter # console
make stop # stop it

# utility
make backup # create a backup now (already does it periodically)
make restore-backup # replaces current world with latest backup

# OPTIONAL setup - see script for details (global status effects)
make install-functions
```

## Startup

### Pregen

Recommend pregeneration of overworld:

```
worldborder center 0 0
worldborder set 6400
pregen start gen worldborder server_startup 0 NORMAL_GEN
```

### Expose server startup

This [setup](./listener/README.md) is optional. It can be skipped.

The server is configured to auto stop when idle for too long. This necessitates a startup mechanism. [listener](./listener) contains a web server that listens to port 25579 and calls `docker compose up -d` when a GET is received (this can be called any number of times, it's only effective if the server is not already running).
