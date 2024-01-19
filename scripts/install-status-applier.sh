#!/bin/bash

# this installs the mc function but it should be called periodically from within
# the server itself (additional setup required). The method is explained in:
# ./modpack-client/overrides/config/ChickenChunks.cfg.notes.txt
# in which case the mentioned placeholder cmd is:
# "/function modpack-server:status-applier",
# and the following must be run manually once:
# "/scoreboard objectives add in_limbo dummy"
# "/scoreboard objectives add just_out_limbo dummy"
set -e
if [ ! -d ./data/word-data/data/functions ]; then
    exit 1
fi
mkdir -p ./data/word-data/data/functions/modpack-server

cp ./scripts/status-applier.mcfunction ./data/word-data/data/functions/modpack-server/status-applier.mcfunction

docker compose exec mc rcon-cli reload
