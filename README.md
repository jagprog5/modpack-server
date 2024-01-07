# John's 1.12.2

This is a dockerized curseforge server for minecraft 1.12.2.

```bash
git clone --recurse-submodules https://github.com/jagprog5/modpack-server
```

It pulls from [this pack](./modpack-client/).

Create the env file:

```bash
cp env .env
```

Then, get a [curseforge api key](https://console.curseforge.com/) and put it in the `.env` file.


Commands (thin wrapper around docker-compose):

```bash
make start # start it
make enter # console
make stop # stop it
```

## Startup

The server is configured to auto stop when idle for too long. This necessitates a startup mechanism.

TODO
