# step 1
FROM node:14.18.0-alpine as node-builder

COPY . .

RUN  yarn install &&\
    yarn build


# step 2
FROM php:7.2-fpm

COPY --from=node-builder . .
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    libzip-dev \
    zip \
    jpegoptim optipng pngquant gifsicle \
    unzip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl
RUN docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer install
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer 
#線上環境如果不需要composer 上面這行可以註解

# RUN php artisan key:generate --ansi &&\ //需要有.env
#     php artisan storage:link //laravel 5.2沒有這個指令


CMD ["php", "artisan", "serve", "--host=0.0.0.0"]

EXPOSE 8000
