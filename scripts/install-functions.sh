#!/bin/bash

# there are two functions which are installed.
# modpack-server:apply-status-effects should not be called by you.
# it is called by the command blocks which are created in the setup-cmd-chunk function (mentioned below)

set -e
if [ ! -d ./data/world-data/data/functions ]; then
    exit 1
fi
mkdir -p ./data/world-data/data/functions/modpack-server

cp ./scripts/apply-status-effects.mcfunction ./data/world-data/data/functions/modpack-server/apply-status-effects.mcfunction
cp ./scripts/setup-cmd-chunk.mcfunction ./data/world-data/data/functions/modpack-server/setup-cmd-chunk.mcfunction
docker compose exec mc rcon-cli reload

echo "LOGIN as a player and RUN:"
echo -e "\t/function modpack-server:setup-cmd-chunk"
