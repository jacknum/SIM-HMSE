FROM php:8.3-fpm

# Install system dependencies + ICU (untuk intl)
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

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

# Copy project
COPY . .

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Install Node dependencies + build Vite
RUN npm install && npm run build

# Permissions Laravel
RUN chmod -R 775 storage bootstrap/cache

# Railway exposes dynamic port
EXPOSE 8080

# Use Railway PORT dynamically (IMPORTANT FIX)
CMD php artisan serve --host=0.0.0.0 --port=$PORT
