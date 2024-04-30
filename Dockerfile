# Usa una imagen base de PHP con Apache
FROM php:8.1-apache

COPY ./web/static/ /var/www/html/

# Actualiza los paquetes e instala cualquier actualización de seguridad necesaria
RUN apt-get update && apt-get upgrade -y

# Instala extensiones adicionales de PHP si es necesario
# RUN docker-php-ext-install mysqli pdo pdo_mysql

# Habilita el mod_rewrite para Apache
RUN a2enmod rewrite

# Copia los archivos del sitio web desde tu directorio local al directorio de Apache
# Asegúrate de que el directorio 'src' contiene tu aplicación PHP


# Expone el puerto 8080 para que sea accesible externamente
EXPOSE 80

# Ejecuta Apache en modo foreground
CMD ["apache2-foreground"]
