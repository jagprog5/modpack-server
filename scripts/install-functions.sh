#!/bin/bash

# there are two functions which are installed.
# modpack-server:apply-status-effects should not be called by you.
# it is called by the command blocks which are created in the setup-cmd-chunk function (mentioned below)

set -e
if [ ! -d ./data/word-data/data/functions ]; then
    exit 1
fi
mkdir -p ./data/word-data/data/functions/modpack-server

cp ./scripts/apply-status-effects.mcfunction ./data/word-data/data/functions/modpack-server/apply-status-effects.mcfunction
cp ./scripts/setup-cmd-chunk.mcfunction ./data/word-data/data/functions/modpack-server/setup-cmd-chunk.mcfunction

# Notch is the owner of the cmd chunk spot loader (an account that will never be used).
# it must be a op account to play well with the chicken chunks config (always loaded)
docker compose exec mc rcon-cli op Notch

docker compose exec mc rcon-cli reload

echo "LOGIN as a player and RUN:"
echo -e "\t/function modpack-server:setup-cmd-chunk"
while true; do
    read -p "Enter 'yes' when prompted inside the game: " user_input
    if [ "$user_input" = "yes" ]; then
        break
    else
        echo "Please enter 'yes' when prompted to"
    fi
done

docker compose restart

echo "restarting. login again to complete the setup."
echo "to ensure it worked, there are two things to check"
echo -e "\t1. check that the status effects are being applied (check effects on you)"
echo -e "\t2. check that the spot loader at the bottom of the cmd chunk is moving (tp ~ 10 ~)"
