
FROM debian:bookworm

ARG DOMAIN_NAME

RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl \
    && openssl req -x509 -nodes -days 365 \
        -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/inception.key \
        -out /etc/nginx/ssl/inception.crt \
        -subj "/C=PT/ST=Lisbon/L=Lisboa/O=42/OU=Inception/CN=${DOMAIN_NAME}"

COPY nginx.conf /etc/nginx/nginx.conf
RUN sed -i "s/DOMAIN_PLACEHOLDER/${DOMAIN_NAME}/" /etc/nginx/nginx.conf

EXPOSE 443
CMD ["nginx", "-g", "daemon off;"]
