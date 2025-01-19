# Use a imagem oficial do PHP 8.1 com FPM
FROM php:8.1-fpm

# Define o diretório de trabalho
WORKDIR /var/www

# Instala as dependências necessárias
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    curl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo_mysql zip \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Instala o Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copia os arquivos da aplicação para o contêiner
COPY . /var/www

# Ajusta as permissões
RUN chown -R www-data:www-data /var/www \
    && chmod -R 755 /var/www/storage

# Instala as dependências do Composer
RUN composer install --no-interaction --optimize-autoloader

# Gera a chave da aplicação e cache de configuração
RUN php artisan key:generate \
    && php artisan config:cache

# Expõe a porta 9000
EXPOSE 9000

# Inicia o servidor do Laravel na porta 9000
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=9000"]
