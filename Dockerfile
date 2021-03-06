FROM ubuntu:18.04

LABEL name="wordpress docker container" \
     version="latest"

ARG DEBIAN_FRONTEND=noninteractive

ARG DUMB_INIT_VERSION=1.2.2

ENV MYSQL_DATABASE=wordpress \
    MYSQL_HOST=localhost \
    MYSQL_PORT=3306 \
    MYSQL_USER=root \
    MYSQL_PASSWORD=secret \
    REDIS_HOST=localhost \
    REDIS_PORT=6379 \
    WP_CLI_PACKAGES_DIR=/opt/wp-cli-packages

RUN apt-get update && apt-get install -y \
    php-xml \
    php-xmlrpc \
    php-curl \
    php-intl \
    php-mbstring \
    php-gd \
    php-zip \
    php-mysql \
    php-redis \
    php-opcache \
    php-fpm \
    php-soap \
    nginx \
    wget \
    unzip \
    sudo \
    curl \
    bats \
    less \
    mysql-client && \
    apt-get upgrade -y && \
    apt-get clean && \
    wget -q https://github.com/Yelp/dumb-init/releases/download/v${DUMB_INIT_VERSION}/dumb-init_${DUMB_INIT_VERSION}_amd64.deb && \
    dpkg -i dumb-init_*.deb && rm dumb-init_*.deb

RUN wget -q https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod 755 wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp && \
    mkdir /app && \
    cd /app && \
    /usr/local/bin/wp core download --allow-root --locale=de_DE && \
    wget -q https://downloads.wordpress.org/plugin/amazon-s3-and-cloudfront.zip && \
    unzip amazon-s3-and-cloudfront.zip && \
    mv amazon-s3-and-cloudfront /app/wp-content/plugins && \
    rm amazon-s3-and-cloudfront.zip && \
    wget -q https://downloads.wordpress.org/plugin/wp-ses.zip && \
    unzip wp-ses.zip && \
    mv wp-ses /app/wp-content/plugins && \
    rm wp-ses.zip && \
    mkdir -p /app/wp-content/languages && \
    cd /app/wp-content/languages && \
    chown -R www-data /var/lib/nginx && \
    mkdir -p /app/wp-content/uploads && \
    chown -R www-data /app/wp-content/uploads

WORKDIR /app

COPY src/wp-config.php /app/wp-config.php
COPY src/amazon-s3-and-cloudfront-tweaks.php /app/wp-content/plugins/amazon-s3-and-cloudfront-tweaks.php
COPY src/amazon-s3-migrate.php /app/amazon-s3-migrate.php
COPY scripts /scripts
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/fpm.conf /etc/php/7.2/fpm/php-fpm.conf
COPY conf/fpm-pool.conf /etc/php/7.2/fpm/pool.d/www.conf

RUN chmod 755 /scripts/*.sh

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

USER www-data

#EXPOSE 8080/tcp
