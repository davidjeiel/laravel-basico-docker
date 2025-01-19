# Utiliza a imagem oficial do PHP 8.1 com FPM
FROM php:8.1-fpm

# Define o diretório de trabalho
WORKDIR /var/www

# Instala as dependências necessárias
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    zip \
    unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo_mysql zip \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Instala o Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copia o código da aplicação para o contêiner
COPY . /var/www

# Ajusta as permissões
RUN chown -R www-data:www-data /var/www

# Expõe a porta utilizada pelo PHP-FPM
EXPOSE 9000

# Comando para iniciar o PHP-FPM
CMD ["php-fpm"]
