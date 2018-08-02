FROM php:7.2-apache

MAINTAINER Marc Apfelbaum karsasmus82@gmail.com

ENV HTTP_DIR /var/www/html
ENV LP_DIR $HTTP_DIR/leafpub

RUN apt-get update && \
    apt-get -y install curl && \
    apt-get -y install unzip git mysql-client && \
    apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libpng-dev && \
    apt-get install -y patch && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install gd && \
    docker-php-ext-install pdo_mysql 

RUN rm -f $HTTP_DIR/index.html && \
    git clone https://github.com/leafpub/leafpub $LP_DIR && \  
    chown www-data. $PL_DIR -R && \
    a2enmod rewrite

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1

RUN composer global require "hirak/prestissimo:^0.3" --prefer-dist --no-progress --no-suggest --optimize-autoloader --classmap-authoritative \
    && composer clear-cache

COPY .htaccess $LP_DIR

WORKDIR LP_DIR

RUN composer install
EXPOSE 80

CMD ["apachectl","-D","FOREGROUND"]
