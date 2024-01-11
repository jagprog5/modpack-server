start:
	(cd modpack-client && rm -f profile.zip && zip -r profile.zip manifest.json overrides > /dev/null)
	docker-compose up -d --remove-orphans

# verbose alias for listener just in case something weird like the wrong makefile is called
start-minecraft-server: start

clean:
	rm -rf data/

stop:
	docker-compose down

enter:
	docker exec -i modpack-server-mc-1 rcon-cli
