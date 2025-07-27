FROM php:8.2-cli

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip 

RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd sockets 

# Install Swoole from source
RUN apt-get install -y \
    libssl-dev \
    libcurl4-openssl-dev \
    build-essential \
    autoconf 

# Install Swoole from PECL (recommended way)
RUN pecl install swoole && docker-php-ext-enable swoole

# Verify Swoole installation
RUN php -m | grep swoole

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy existing application directory contents
COPY . /var/www

# Install PHP dependencies
RUN composer install --optimize-autoloader

# Create storage and bootstrap/cache directories if they don't exist
RUN mkdir -p storage/logs storage/framework/{cache,sessions,views} bootstrap/cache

# Set permissions
RUN chown -R www-data:www-data /var/www 
RUN chmod -R 777 /var/www/storage 
RUN chmod -R 777 /var/www/bootstrap/cache

# Expose port 8000
EXPOSE 8000
EXPOSE 9000
