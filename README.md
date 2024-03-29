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

make backup # create a backup now (already does it periodically)
make restore-backup # replaces current world with latest backup
make install-functions # see script for details
```

## Startup

This [setup](./listener/README.md) is optional. It can be skipped.

The server is configured to auto stop when idle for too long. This necessitates a startup mechanism. [listener](./listener) contains a web server that listens to port 25579 and calls the above `make start` when a GET is received (this can be called any number of times, it's only effective if the server is not already running).
