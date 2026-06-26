#!/bin/bash

cd /var/www/html

WORDPRESS_ADMIN_PASSWORD=$(cat /run/secrets/wp_pass)
WORDPRESS_PASSWORD=$(cat /run/secrets/db_pass)
USER_PASSWORD=$(cat /run/secrets/user_pass)

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar

./wp-cli.phar core download --allow-root --path=/var/www/html

./wp-cli.phar config create \
  --path=/var/www/html \
  --dbhost=mariadb \
  --dbname=${WORDPRESS_NAME} \
  --dbuser=${WORDPRESS_USER} \
  --dbpass=${WORDPRESS_PASSWORD} \
  --allow-root

./wp-cli.phar core install \
  --path=/var/www/html \
  --url=${DOMAIN_NAME} \
  --title=${WORDPRESS_TITLE} \
  --admin_user=${WORDPRESS_ADMIN_USER} \
  --admin_email=${WORDPRESS_ADMIN_EMAIL} \
  --allow-root

  ./wp-cli.phar user create \
    ${USER_NAME} \
    ${USER_EMAIL} \
    --user_pass=${USER_PASS} \
    --allow-root

exec php-fpm8.2 -F