#!/bin/bash

# Configura Apache para que escuche en el puerto 5000
sed -i 's/Listen 80/Listen 5000/' /etc/apache2/ports.conf
sed -i 's/<VirtualHost \*:80>/<VirtualHost *:5000>/' /etc/apache2/sites-available/000-default.conf

# Ejecuta Apache en primer plano
apache2-foreground
