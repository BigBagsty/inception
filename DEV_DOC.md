# Developer Documentation

## Prerequisites

- A Linux virtual machine with Docker Engine and the Docker Compose plugin.
- `make` and `sudo` (used by `make fclean` to delete the data folders).
- A free port 443 on the VM.

## Layout

```
.
├── Makefile
├── secrets/                  (not committed)
│   ├── db_pass.txt
│   ├── db_root_pass.txt
│   ├── wp_pass.txt
│   └── user_pass.txt
└── srcs/
    ├── .env                  (not committed, see .env.example)
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/   Dockerfile, 50-server.cnf, entry.sh
        ├── nginx/     Dockerfile, nginx.conf
        └── wordpress/ Dockerfile, www.conf, script.sh
```

## Setup from scratch

1. Add `127.0.0.1 <login>.42.fr` to `/etc/hosts`.
2. Create the four files in `secrets/`, one password each, no trailing spaces. Avoid the `'` character in passwords, they are inserted into an SQL statement.
3. `cp srcs/.env.example srcs/.env` and edit it. `DOMAIN_NAME` must be `<login>.42.fr`. The `LOGIN` variable used by compose comes from the Makefile (`$USER`), so do not set it in `.env`.
4. `make`

## Build and run

| Command | What it does |
|---|---|
| `make` / `make up` | Creates `/home/<login>/data/{mariadb,wordpress}`, builds the images and starts the containers |
| `make down` | Stops and removes the containers and network (volumes and data stay) |
| `make start` / `make stop` | Starts / stops the existing containers |
| `make logs`, `make ps` | Logs and status |
| `make clean` | `down` plus removal of volumes and images |
| `make fclean` | `clean` plus deletion of `/home/<login>/data` |
| `make re` | `fclean` then `all` |

Equivalent without the Makefile: `LOGIN=$USER docker compose -f srcs/docker-compose.yml up -d --build`.

## Useful container commands

- Shell in a container: `docker exec -it wordpress bash` (use `sh` for mariadb)
- Follow one service: `docker compose -f srcs/docker-compose.yml logs -f nginx`
- Database access: `docker exec -it mariadb mariadb -uroot -p`
- WP-CLI: `docker exec -it wordpress wp --allow-root --path=/var/www/html user list`
- Inspect volumes: `docker volume ls`, `docker volume inspect srcs_db`

## How the services initialise

- **mariadb** (`entry.sh`): on first start only (no `/var/lib/mysql/mysql`), it runs `mariadb-install-db`, then runs `mariadbd --bootstrap` once with a SQL script that creates the WordPress database and user from `.env` and the secrets and sets the root password. That run exits by itself, so nothing runs in the background. Afterwards `mariadbd` runs as PID 1.
- **wordpress** (`script.sh`): waits for mariadb on port 3306, downloads WordPress and creates `wp-config.php` if missing, installs the site and creates the second user if they do not exist yet, fixes file ownership for `www-data`, then runs `php-fpm8.2 -F` as PID 1. It can be restarted safely.
- **nginx**: the domain name is passed as a build argument and used for the certificate CN and `server_name`. Requests for `.php` files go to `wordpress:9000` through FastCGI.

Changing `DOMAIN_NAME` requires a rebuild (`make re`).

## Data persistence

Two named volumes use the local driver with `type: none, o: bind`:

| Volume | Container path | Host path |
|---|---|---|
| `db` | `/var/lib/mysql` | `/home/<login>/data/mariadb` |
| `press` | `/var/www/html` | `/home/<login>/data/wordpress` |

Data survives `make down`, `make stop` and rebuilds. It is only deleted by `make fclean` (and `make re`). The `press` volume is shared by wordpress and nginx so nginx can serve static files and find the PHP scripts at the same path.