# Usa una imagen base con Apache y PHP
FROM php:apache

# Copia los archivos de la aplicación estática al directorio de trabajo en el contenedor
COPY ./web/static/ /var/www/html/

# Copia el archivo de configuración predeterminado de Apache que sirve el index.html
COPY apache-default.conf /etc/apache2/sites-available/000-default.conf

# Exponer el puerto 80 para que Apache pueda recibir solicitudes
EXPOSE 5000

# El contenedor de Apache se ejecuta en primer plano para mantenerlo en ejecución
CMD ["apache2-foreground"]