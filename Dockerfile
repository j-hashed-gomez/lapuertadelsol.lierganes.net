# Usa una imagen base de PHP con Apache
FROM php:8.0-apache

WORKDIR /var/www/html/

COPY ./web/static/ /var/www/html/
RUN chmod +x /var/www/html/check_update_hashes.sh
RUN touch /var/www/html/uploads/file_changes.log
RUN chmod -R 755 /var/www/html/uploads
RUN chmod +x /var/www/html/update.py
RUN touch /var/log/cron.log
RUN chown -R www-data:www-data /var/www/html/

# Crea el archivo .htpasswd y añade las líneas con los usuarios y contraseñas
RUN echo 'jose:$2y$05$Z/PtGDfz9yJPvblW7xMcNOT8utvLmPl2Rw1F5Ej6mqfc7GUrejz8O' > /var/www/html/.htpasswd \
    && echo 'esteban:$2y$05$iIw5IJr9..SpvXjVM97z0ebVmfkAq84osCuumE4YikkvufsgjVamu' >> /var/www/html/.htpasswd \
    && echo 'agus:$2y$05$a5t8RLODmnIhxgWoD.73xOiBzrwhIITIhL/CxcuK0CXxP9XFEyHj.' >> /var/www/html/.htpasswd

# Asegúrate de que el archivo .htpasswd tiene los permisos adecuados
RUN chmod 644 /var/www/html/.htpasswd

RUN docker-php-ext-install zip
# Instalar el módulo zip de PHP
RUN apt-get update && apt-get install -y libzip-dev && docker-php-ext-install zip

# Actualiza los paquetes e instala cualquier actualización de seguridad necesaria
RUN apt-get update && apt-get upgrade -y && apt-get install -y cron python3 python3-pip python3.11-venv python3-dotenv nano zip




# Crear un entorno virtual dentro del contenedor y activarlo
RUN python3 -m venv /venv
ENV PATH="/venv/bin:$PATH"

# Configura AllowOverride para el directorio de Apache
RUN sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

# Habilita el mod_rewrite para Apache
RUN a2enmod rewrite

# Copia los archivos del sitio web desde tu directorio local al directorio de Apache
# Asegúrate de que el directorio 'src' contiene tu aplicación PHP


# Expone el puerto 8080 para que sea accesible externamente
EXPOSE 80

# Comando para arrancar cron y Apache en primer plano
CMD cron && apache2-foreground