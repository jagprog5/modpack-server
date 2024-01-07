start:
	docker-compose up -d --remove-orphans

clean:
	rm -rf data/

stop:
	docker-compose down

enter:
	docker exec -i `docker container ls | grep itzg/minecraft-server:java8-multiarch | cut -d' ' -f1` rcon-cli
