FROM php:8.3-fpm

RUN apt-get update && apt-get install -y \
    git curl unzip zip \
    nodejs npm \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libicu-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd intl zip pdo pdo_mysql

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

COPY . .

# install PHP deps dulu
RUN composer install --no-dev --optimize-autoloader --no-interaction

# install node deps + build
RUN npm ci || npm install
RUN npm run build

# 🔥 IMPORTANT: pastikan manifest ada
RUN ls -la public/build

RUN chmod -R 775 storage bootstrap/cache

EXPOSE 8080

CMD php artisan serve --host=0.0.0.0 --port=$PORT
