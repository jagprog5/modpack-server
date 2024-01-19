start:
	(cd modpack-client && rm -f profile.zip && zip -r profile.zip manifest.json overrides > /dev/null)
	docker compose up -d --remove-orphans

stop:
	docker compose down

enter:
	docker compose exec -i mc rcon-cli

backup:
	docker compose exec backups backup now

restore-backup:
	./scripts/restore-backup.sh

install-status-applier:
	./scripts/install-status-applier.sh
