# Build stage for frontend assets
FROM node:20-alpine AS frontend

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY resources ./resources
COPY vite.config.js ./

RUN npm run build


# Production stage
FROM php:8.3-fpm-alpine

# Install system dependencies
RUN apk add --no-cache \
    nginx \
    supervisor \
    sqlite \
    sqlite-dev \
    curl \
    zip \
    unzip \
    git \
    libzip-dev \
    icu-dev \
    && docker-php-ext-install pdo pdo_sqlite zip intl

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copy composer files first for better caching
COPY composer.json composer.lock ./

# Create required directories before composer install
RUN mkdir -p storage/framework/{sessions,views,cache} storage/logs bootstrap/cache database \
    && chown -R www-data:www-data storage bootstrap/cache database

# Install PHP dependencies (ignore platform reqs for Alpine compatibility)
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-scripts --ignore-platform-reqs

# Copy application files
COPY --chown=www-data:www-data . .

# Copy built frontend assets
COPY --from=frontend --chown=www-data:www-data /app/public/build ./public/build

# Clear any cached config and ensure proper ownership
RUN rm -rf bootstrap/cache/*.php \
    && chown -R www-data:www-data storage bootstrap/cache database

# Copy nginx config
COPY docker/nginx.conf /etc/nginx/http.d/default.conf

# Copy supervisor config
COPY docker/supervisord.conf /etc/supervisord.conf

# Copy entrypoint
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
