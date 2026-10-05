FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    mariadb-server \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/lib/mysql /run/mysqld \
    && chown -R mysql:mysql /var/lib/mysql /run/mysqld

COPY 50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY entry.sh /entry.sh
RUN chmod +x /entry.sh

EXPOSE 3306
ENTRYPOINT ["/entry.sh"]
CMD ["mariadbd"]