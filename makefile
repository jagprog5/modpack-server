start:
	(cd modpack-client && ./scripts/export_profile.py profile.zip)
	docker compose up -d --remove-orphans

stop:
	docker compose down

enter:
	docker compose exec -i mc rcon-cli

backup:
	docker compose exec backups backup now

restore-backup:
	./scripts/restore-backup.sh

install-functions:
	./scripts/install-functions.sh
