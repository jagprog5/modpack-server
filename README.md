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
```

## Startup

### Pregen

Consider pregeneration of overworld:

```
make enter
pregen start gen radius server_startup SQUARE 0 0 220 0 NORMAL_GEN
```

That command pregenerates the overworld  ~3500 blocks in each direction. It
takes a long time to complete. The server is join-able while it's running, but
will be laggy in the mean time.

### Expose server startup

This [setup](./listener/README.md) is optional. It can be skipped.

The server is configured to auto stop when idle for too long. This necessitates
a startup mechanism. [listener](./listener) contains a web server that listens
to port 25579 and calls `docker compose up -d` when a GET is received (this can
be called any number of times, it's only effective if the server is not already
running).
