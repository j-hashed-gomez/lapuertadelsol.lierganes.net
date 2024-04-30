# Usa una imagen base con Apache y PHP
FROM php:apache

# Copia los archivos de la aplicación estática al directorio de trabajo en el contenedor
COPY ./web/static/ /var/www/html/

# Copia el archivo de configuración predeterminado de Apache que sirve el index.html
COPY apache-default.conf /etc/apache2/sites-available/000-default.conf

# Copia el nuevo script de inicio
COPY start-apache.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start-apache.sh

EXPOSE 5000

# Establece el nuevo script de inicio como el punto de entrada del contenedor
ENTRYPOINT ["start-apache.sh"]