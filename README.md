*This project has been created as part of the 42 curriculum by <fragarc2>.*

# Inception

## Description

Inception builds a small web infrastructure with Docker Compose inside a virtual machine. Every service is built from its own Dockerfile on top of Debian Bookworm (no pre-made images):

- **nginx**: the only entry point, HTTPS on port 443, TLSv1.3 only, self-signed certificate.
- **wordpress + php-fpm**: WordPress installed and configured automatically with WP-CLI.
- **mariadb**: the database used by WordPress, initialised on first start.

The three containers share a dedicated Docker network. Database files and website files live in two persistent volumes stored under `/home/<login>/data`. Passwords are provided as Docker secrets, other settings through `srcs/.env`.

### Design choices

**Virtual Machines vs Docker.** A VM virtualises a whole machine with its own kernel, so it is heavy and slow to start but strongly isolated. A container shares the host kernel and only packages the process and its dependencies, so it starts in seconds and uses far fewer resources, with weaker isolation. Here Docker is used for the services, and the VM is only the host that runs them.

**Secrets vs Environment Variables.** Environment variables are easy to use but are visible in `docker inspect` and are inherited by child processes. Docker secrets are mounted as files under `/run/secrets/` and only given to the services that need them. Passwords use secrets; non-sensitive configuration (domain, usernames, site title) uses `.env`.

**Docker Network vs Host Network.** With host networking a container uses the host's network stack directly, with no isolation and risk of port clashes. A user-defined bridge network (`inception`) gives containers private addresses and DNS by service name (`mariadb`, `wordpress`), and only nginx publishes a port (443).

**Docker Volumes vs Bind Mounts.** A bind mount maps a host path into the container, tied to the host's directory layout. A named volume is managed by Docker and referenced by name. This project uses named volumes configured with the `bind` driver option, so they are declared as volumes in the compose file but the data is stored in `/home/<login>/data`, as the subject requires.

## Instructions

1. Add the domain to `/etc/hosts`: `127.0.0.1 <login>.42.fr`
2. Create the secrets (one password per file, in `secrets/`): `db_pass.txt`, `db_root_pass.txt`, `wp_pass.txt`, `user_pass.txt`.
3. Copy `srcs/.env.example` to `srcs/.env` and fill it in (`DOMAIN_NAME` must be `<login>.42.fr`).
4. Run `make`, then open `https://<login>.42.fr`.

Other targets: `make down`, `make stop`, `make start`, `make logs`, `make ps`, `make clean`, `make fclean`, `make re`. See `USER_DOC.md` and `DEV_DOC.md` for details.

## Resources

- Docker documentation: https://docs.docker.com
- Docker Compose file reference: https://docs.docker.com/compose/compose-file/
- nginx documentation: https://nginx.org/en/docs/
- MariaDB knowledge base: https://mariadb.com/kb/en/
- WP-CLI handbook: https://make.wordpress.org/cli/handbook/
- PHP-FPM configuration: https://www.php.net/manual/en/install.fpm.configuration.php

**Use of AI:** AI was used to review the configuration and scripts and to help draft the documentation. All generated content was read, tested and understood before being kept.
