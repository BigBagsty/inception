export LOGIN := $(USER)
DATA     := /home/$(LOGIN)/data
COMPOSE  := docker compose --env-file ./srcs/.env -f ./srcs/docker-compose.yml

all: up

up:
	@mkdir -p $(DATA)/mariadb $(DATA)/wordpress
	@$(COMPOSE) up -d --build

down:
	@$(COMPOSE) down

start:
	@$(COMPOSE) start

stop:
	@$(COMPOSE) stop

logs:
	@$(COMPOSE) logs

ps:
	@$(COMPOSE) ps

clean:
	@$(COMPOSE) down -v --rmi all

fclean: clean
	@sudo rm -rf $(DATA)

re: fclean all

.PHONY: all up down start stop logs ps clean fclean re