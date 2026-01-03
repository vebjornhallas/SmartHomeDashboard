#!/bin/sh

# Ensure storage directories exist
mkdir -p storage/framework/{sessions,views,cache} storage/logs bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache

# Ensure database directory and file exist
mkdir -p database/data
if [ ! -f database/data/database.sqlite ]; then
    touch database/data/database.sqlite
    echo "Created new SQLite database"
fi
chown -R www-data:www-data database
chmod 664 database/data/database.sqlite

# Create symlink so Laravel finds the database
ln -sf /var/www/html/database/data/database.sqlite /var/www/html/database/database.sqlite

# Create .env from example if it doesn't exist
if [ ! -f .env ]; then
    cp .env.example .env
    echo "Created .env from .env.example"
fi

# Clear cached config
rm -rf bootstrap/cache/*.php 2>/dev/null || true

# Generate app key if needed
if ! grep -q "^APP_KEY=base64:" .env; then
    php artisan key:generate --force
    echo "Generated new APP_KEY"
fi

# Run migrations
echo "Running migrations..."
php artisan migrate --force
echo "Migrations complete"

# Cache for production
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "=========================================="
echo "  Homey Dashboard is starting..."
echo "  Access at: http://localhost:${PORT:-8080}"
echo "=========================================="

exec "$@"
