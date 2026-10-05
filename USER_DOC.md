# User Documentation

## What the stack provides

| Service | Role |
|---|---|
| nginx | HTTPS entry point (port 443), the only service reachable from outside |
| wordpress | The WordPress website (PHP-FPM) |
| mariadb | The database that stores the site content and users |

## Start and stop

From the project root:

- Start (builds if needed): `make`
- Stop and remove containers (data is kept): `make down`
- Pause / resume without removing: `make stop` / `make start`
- Remove everything including data: `make fclean`

## Access the website

1. Make sure `/etc/hosts` contains `127.0.0.1 <login>.42.fr`.
2. Website: `https://<login>.42.fr`
3. Administration panel: `https://<login>.42.fr/wp-admin`

The certificate is self-signed, so the browser shows a warning the first time. Accept it to continue.

## Credentials

- Usernames and emails are in `srcs/.env` (`WORDPRESS_ADMIN_USER`, `USER_NAME`, ...).
- Passwords are in the `secrets/` folder:
  - `wp_pass.txt`: WordPress administrator password
  - `user_pass.txt`: second WordPress user (author) password
  - `db_pass.txt`: password the WordPress user uses for the database
  - `db_root_pass.txt`: MariaDB root password

Changing a password file after the first start does not change it in WordPress or MariaDB. Use the WordPress admin panel, or run `make fclean` and start again (this deletes all data).

## Check that everything works

- `make ps`: all three containers should be `Up`.
- `make logs`: shows the output of the three services.
- Opening `https://<login>.42.fr` should show the WordPress site.
- Logging in at `/wp-admin` with the admin user confirms the database connection works.
