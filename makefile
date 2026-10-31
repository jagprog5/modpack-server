# exclude:
# - camouflage creepers (client side only and breaks server side)
start:
	(cd modpack-client && ./scripts/export_profile.py profile.zip)
	./forge_to_pack.py ./modpack-client/profile.zip --exclude 244447 -o pack.zip && rm ./modpack-client/profile.zip
	docker compose up -d --remove-orphans

stop:
	docker compose down

enter:
	docker compose exec -i mc rcon-cli

backup:
	docker compose exec backups backup now

restore-backup:
	./scripts/restore-backup.sh
