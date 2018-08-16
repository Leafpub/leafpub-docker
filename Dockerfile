FROM php:7.2-apache

MAINTAINER Marc Apfelbaum karsasmus82@gmail.com

ENV HTTP_DIR /var/www/html
ENV LP_DIR $HTTP_DIR/leafpub

RUN apt-get update && \
    apt-get -y install curl nano && \
    apt-get -y install unzip git mysql-client gnupg && \
    apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libpng-dev && \
    apt-get install -y patch && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install gd && \
    docker-php-ext-install pdo_mysql 

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && apt-get install -y nodejs build-essential

RUN rm -f $HTTP_DIR/index.html && \
    git clone https://github.com/leafpub/leafpub $LP_DIR && \  
    git clone https://github.com/leafpub/range $LP_DIR/app/content/themes/range && \  
    chown www-data. $LP_DIR -R && \
    a2enmod rewrite

#COPY server-apache2-vhosts.conf /etc/apache2/sites-enabled/leafpub.conf
#RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
ADD server-apache2-vhosts.conf /etc/apache2/sites-enabled/000-default.conf

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1

RUN composer global require "hirak/prestissimo:^0.3" --prefer-dist --no-progress --no-suggest --optimize-autoloader --classmap-authoritative \
    && composer clear-cache

COPY .htaccess $LP_DIR/app

WORKDIR $LP_DIR

RUN npm i -g gulp

RUN composer install
EXPOSE 80

CMD ["apachectl","-D","FOREGROUND"]
