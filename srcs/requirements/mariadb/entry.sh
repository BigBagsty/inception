#!/bin/sh
set -e

DB_PASS=$(cat /run/secrets/db_pass)
DB_ROOT_PASS=$(cat /run/secrets/db_root_pass)

mkdir -p /run/mysqld /var/lib/mysql
chown -R mysql:mysql /run/mysqld /var/lib/mysql

# First start: create the system tables.
if [ ! -d /var/lib/mysql/mysql ]; then
    echo "[entry] creating system tables"
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null
fi

# Every start: make sure the WordPress database and user exist. Bootstrap mode
# runs the SQL in the foreground and exits by itself (nothing in the background).
# Every statement is safe to repeat, so a stale or half-set-up data folder heals.
echo "[entry] applying database setup for ${WORDPRESS_NAME} / ${WORDPRESS_USER}"
mariadbd --user=mysql --bootstrap <<SQL
FLUSH PRIVILEGES;
DROP DATABASE IF EXISTS test;
CREATE DATABASE IF NOT EXISTS \`${WORDPRESS_NAME}\`;
CREATE USER IF NOT EXISTS '${WORDPRESS_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
ALTER USER '${WORDPRESS_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${WORDPRESS_NAME}\`.* TO '${WORDPRESS_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
FLUSH PRIVILEGES;
SQL
echo "[entry] setup done, starting mariadbd"

exec "$@"