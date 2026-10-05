#!/bin/bash
set -e

cd /var/www/html

WORDPRESS_ADMIN_PASSWORD=$(cat /run/secrets/wp_pass)
WORDPRESS_PASSWORD=$(cat /run/secrets/db_pass)
USER_PASSWORD=$(cat /run/secrets/user_pass)

WP="wp --allow-root --path=/var/www/html"

# MariaDB only opens TCP once its first-run setup is finished.
for i in $(seq 1 60); do
    (echo > /dev/tcp/mariadb/3306) 2> /dev/null && break
    echo "Waiting for mariadb ($i/60)..."
    sleep 1
done
(echo > /dev/tcp/mariadb/3306) 2> /dev/null || { echo "mariadb unreachable"; exit 1; }

if [ ! -f wp-config.php ]; then
    [ -f wp-includes/version.php ] || $WP core download
    $WP config create \
        --dbhost=mariadb \
        --dbname="${WORDPRESS_NAME}" \
        --dbuser="${WORDPRESS_USER}" \
        --dbpass="${WORDPRESS_PASSWORD}"
fi

if ! $WP core is-installed; then
    $WP core install \
        --url="https://${DOMAIN_NAME}" \
        --title="${WORDPRESS_TITLE}" \
        --admin_user="${WORDPRESS_ADMIN_USER}" \
        --admin_password="${WORDPRESS_ADMIN_PASSWORD}" \
        --admin_email="${WORDPRESS_ADMIN_EMAIL}" \
        --skip-email
fi

if ! $WP user get "${USER_NAME}" > /dev/null 2>&1; then
    $WP user create \
        "${USER_NAME}" \
        "${USER_EMAIL}" \
        --user_pass="${USER_PASSWORD}" \
        --role=author
fi

# wp-cli ran as root; php-fpm runs as www-data and must be able to write.
chown -R www-data:www-data /var/www/html

exec php-fpm8.2 -F