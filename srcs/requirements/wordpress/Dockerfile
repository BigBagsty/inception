FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php-fpm \
    php-mysqli \
    php-cli \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY script.sh /script.sh
RUN chmod +x /script.sh

CMD ["/script.sh"]