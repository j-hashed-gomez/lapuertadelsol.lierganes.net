#!/bin/bash

# Directorio donde se encuentran los archivos para calcular hash
DIR="/var/www/html/uploads"

# Archivo donde están almacenados los hashes anteriores
HASH_FILE="/var/www/html/uploads/fechas_ini"

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
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Hash actualizado para $file." >> /var/www/html/log_update_hashes.log
    insert_content "$file"
    reload_apache
}

# Función para insertar contenido en el archivo HTML
insert_content() {
    local file="$1"
    local line='INSERT HERE'
    local html_file="/var/www/html/${file%.txt}.html"
    local temp_file=$(mktemp)
    local counter=1
    # Lee el archivo línea por línea
    while IFS= read -r item; do
        # Formato de la fila a insertar
        echo "    <tr>" >> "$temp_file"
        echo "      <th scope=\"row\">$counter</th>" >> "$temp_file"
        echo "      <td colspan=\"2\">$item</td>" >> "$temp_file"
        echo "      <td>precio €</td>" >> "$temp_file"
        echo "    </tr>" >> "$temp_file"
        ((counter++))
    done < "$DIR/$file"
    # Inserta las nuevas filas debajo de "INSERT HERE"
    awk -v line="$line" -v file="$temp_file" \
        '/INSERT HERE/ {print; while ((getline line < file) > 0) { print line }; next}1' \
        "$html_file" > "${html_file}.tmp" && mv "${html_file}.tmp" "$html_file"
    rm "$temp_file"
}

# Función para recargar Apache
reload_apache() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Reloading Apache server."
    /usr/sbin/apachectl graceful
}

# Procesa cada archivo
for file in "${FILES[@]}"; do
    filepath="${DIR}/${file}"
    if [[ -f "$filepath" ]]; then
        current_hash=$(get_md5 "$filepath")
        # Busca el hash guardado que coincide con el nombre del archivo
        saved_hash=$(awk -F'::' -v file="$file" '$1 == file {print $2}' "$HASH_FILE")
        
        if [[ "$current_hash" != "$saved_hash" ]]; then
            # Si los hashes son diferentes, actualiza el hash en fechas_ini
            update_hash "$file" "$current_hash"
        fi
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - El archivo ${file} no existe en el directorio ${DIR}." >> /var/www/html/log_update_hashes.log
    fi
done

echo "$(date '+%Y-%m-%d %H:%M:%S') - Proceso de verificación y actualización completado." >> /var/www/html/log_update_hashes.log
