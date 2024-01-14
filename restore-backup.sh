#!/bin/bash
set -e
echo "Are you sure you want to stop the server and overwrite the current world"
echo "and replace it with the latest backup? (yes/no)"
read answer
if [ "$answer" != "yes" ]; then
    exit 1
fi


# prevent startup from happening during next operations
sudo systemctl stop minecraft-startup-listener.service
# stop the server
make stop
# clear server data
mv data "data_replaced_on_`date +%s`"
# replace the server data
docker-compose run restore-backup restore-tar-backup

make start

# continue op
sudo systemctl start minecraft-startup-listener.service
