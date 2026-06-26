all: up

up:
	@docker compose -f ./srcs/docker-compose.yml up -d

down: 
	@docker compose -f ./srcs/docker-compose.yml down

rebuild: clean
	@docker compose -f ./srcs/docker-compose.yml build --no-cache

logs: 
	@docker compose -f ./srcs/docker-compose.yml logs mariadb
	@docker compose -f ./srcs/docker-compose.yml logs wordpress
	@docker compose -f ./srcs/docker-compose.yml logs nginx

clean: down
	sudo rm -rf /home/aaleixo-/data/mariadb/*
	sudo rm -rf /home/aaleixo-/data/wordpress/*

ps: 
	@docker compose -f ./srcs/docker-compose.yml ps