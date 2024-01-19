#!/bin/bash
set -e
echo "Are you sure you want to restart the server and overwrite the current world"
echo "and replace it with the latest backup? (yes/no)"
read answer
if [ "$answer" != "yes" ]; then
    exit 1
fi


# prevent startup from happening during next operations
sudo systemctl stop minecraft-startup-listener.service
trap 'echo WARNING: minecraft-startup-listener.service was not restarted since the script erred. start it if desired' ERR SIGINT SIGTERM

# stop the server
docker compose down
# clear server data
mv data "data_replaced_on_`date +%s`"

# loads the last saved data
docker compose up -d --remove-orphans

sudo systemctl start minecraft-startup-listener.service
