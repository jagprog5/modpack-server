# this can be safely called repeatedly. no need to rate limit or throttle. it only does something if it isn't already running
start:
	docker-compose up -d --remove-orphans

# verbose alias for listener just in case something weird like the wrong makefile is called
start-minecraft-server: start

clean:
	rm -rf data/

stop:
	docker-compose down

enter:
	docker exec -i `docker container ls | grep itzg/minecraft-server:java8-multiarch | cut -d' ' -f1` rcon-cli
