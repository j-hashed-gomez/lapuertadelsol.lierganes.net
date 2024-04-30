#!/bin/bash

# Directorio donde se encuentran los archivos
DIR="/var/www/html/uploads"

# Archivo de salida donde se guardarán las fechas
OUTPUT_FILE="${DIR}/fechas_ini"

# Limpiar el archivo de salida o crearlo si no existe
> "$OUTPUT_FILE"

# Lista de archivos específicos para procesar
FILES=("carta.txt" "raciones.txt" "bocadillos.txt")

# Bucle para recorrer cada archivo
for file in "${FILES[@]}"; do
    # Comprueba si el archivo existe
    if [[ -f "${DIR}/${file}" ]]; then
        # Obtiene la fecha de última modificación en el formato AAAAMMDDHHMMSS
        mod_date=$(date -r "${DIR}/${file}" +"%Y%m%d%H%M%S")
        # Escribe el resultado en el archivo de salida
        echo "${file}:${mod_date}" >> "$OUTPUT_FILE"
    else
        echo "El archivo ${file} no existe en el directorio ${DIR}."
    fi
done

echo "Proceso completado. Las fechas de modificación han sido guardadas en ${OUTPUT_FILE}."
