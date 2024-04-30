#!/bin/bash

# Directorio donde se encuentran los archivos para calcular hash
DIR="/var/www/html/uploads"

# Archivo donde están almacenados los hashes anteriores
HASH_FILE="/var/www/html/fechas_ini"

# Archivos específicos para procesar
FILES=("carta.txt" "raciones.txt" "bocadillos.txt")

# Función para obtener el hash MD5 de un archivo
get_md5() {
    md5sum "$1" | awk '{ print $1 }'
}

# Función para actualizar el hash en el archivo de hashes
update_hash() {
    local file=$1
    local new_hash=$2
    # Usa sed para reemplazar el hash antiguo por el nuevo
    sed -i "s|^${file}::.*|${file}::${new_hash}|" "$HASH_FILE"
}

# Procesa cada archivo
for file in "${FILES[@]}"; do
    filepath="${DIR}/${file}"
    if [[ -f "$filepath" ]]; then
        current_hash=$(get_md5 "$filepath")
        # Busca el hash guardado que coincide con el nombre del archivo
        saved_hash=$(grep "^${file}::" "$HASH_FILE" | cut -d'::' -f2)
        
        if [[ "$current_hash" != "$saved_hash" ]]; then
            # Si los hashes son diferentes, actualiza el hash en fechas_ini
            update_hash "$file" "$current_hash"
            echo "Hash actualizado para $file."
        fi
    else
        echo "El archivo ${file} no existe en el directorio ${DIR}."
    fi
done

echo "Proceso de verificación y actualización completado."
