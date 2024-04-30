# Usa una imagen base con Apache y PHP
FROM php:apache

# Copia los archivos de la aplicación estática al directorio de trabajo en el contenedor
COPY ./web/static/ /var/www/html/

# Exponer el puerto 80 para que Apache pueda recibir solicitudes
EXPOSE 5000

# El contenedor de Apache se ejecuta en primer plano para mantenerlo en ejecución
CMD ["apache2-foreground"]