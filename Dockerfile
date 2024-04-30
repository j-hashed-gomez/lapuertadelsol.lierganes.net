# Usa una imagen base de PHP con Apache
FROM php:8.1-apache

COPY ./web/static/ /var/www/html/

# Actualiza los paquetes e instala cualquier actualización de seguridad necesaria
RUN apt-get update && apt-get upgrade -y

# Instala extensiones adicionales de PHP si es necesario
# RUN docker-php-ext-install mysqli pdo pdo_mysql

# Cambia el puerto en el que Apache escucha por defecto (80) al 8080
RUN sed -i 's/Listen 80/Listen 8080/' /etc/apache2/ports.conf
RUN sed -i 's/<VirtualHost \*:80>/<VirtualHost \*:8080>/' /etc/apache2/sites-available/000-default.conf

# Habilita el mod_rewrite para Apache
RUN a2enmod rewrite

# Copia los archivos del sitio web desde tu directorio local al directorio de Apache
# Asegúrate de que el directorio 'src' contiene tu aplicación PHP
COPY ./src/ /var/www/html/

# Expone el puerto 8080 para que sea accesible externamente
EXPOSE 8080

# Ejecuta Apache en modo foreground
CMD ["apache2-foreground"]
