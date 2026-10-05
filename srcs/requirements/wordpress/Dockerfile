FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php-fpm \
    php-mysql \
    php-cli \
    php-curl \
    php-gd \
    php-mbstring \
    php-xml \
    php-zip \
    php-intl \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL -o /usr/local/bin/wp \
        https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp \
    && mkdir -p /run/php /var/www/html

COPY www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY script.sh /script.sh
RUN chmod +x /script.sh

WORKDIR /var/www/html
EXPOSE 9000
CMD ["/script.sh"]