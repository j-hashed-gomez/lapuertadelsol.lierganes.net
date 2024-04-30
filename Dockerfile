# Usa una imagen base de PHP con Apache
FROM php:8.1-apache

COPY ./web/static/ /var/www/html/
RUN mkdir -p /var/www/html/uploads
RUN chmod 755 /var/www/html/uploads
RUN chown www-data:www-data /var/www/html/uploads

# Crea el archivo .htpasswd y añade las líneas con los usuarios y contraseñas
RUN echo 'jose:$2y$05$Z/PtGDfz9yJPvblW7xMcNOT8utvLmPl2Rw1F5Ej6mqfc7GUrejz8O' > /var/www/html/.htpasswd \
    && echo 'esteban:$2y$05$iIw5IJr9..SpvXjVM97z0ebVmfkAq84osCuumE4YikkvufsgjVamu' >> /var/www/html/.htpasswd \
    && echo 'agus:$2y$05$a5t8RLODmnIhxgWoD.73xOiBzrwhIITIhL/CxcuK0CXxP9XFEyHj.' >> /var/www/html/.htpasswd

# Asegúrate de que el archivo .htpasswd tiene los permisos adecuados
RUN chmod 644 /var/www/html/.htpasswd

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
