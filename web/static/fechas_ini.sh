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
        # Calcula el hash MD5 del archivo
        md5_hash=$(md5sum "${DIR}/${file}" | awk '{ print $1 }')
        # Escribe el resultado en el archivo de salida con el formato deseado
        echo "${file}::${md5_hash}" >> "$OUTPUT_FILE"
    else
        echo "El archivo ${file} no existe en el directorio ${DIR}."
    fi
done

echo "Proceso completado. Los hashes MD5 han sido guardados en ${OUTPUT_FILE}."