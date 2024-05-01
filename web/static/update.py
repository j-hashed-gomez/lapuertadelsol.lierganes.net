import hashlib
import os
from datetime import datetime
from dotenv import load_dotenv, set_key

# Carga las variables de entorno desde el archivo .env
dotenv_path = "/var/www/html/uploads/.env"
load_dotenv(dotenv_path)

# Ruta donde se encuentran los archivos
directory = "/var/www/html/uploads"
# Lista de nombres de ficheros
files = ["carta_carnes.txt", "carta_pescados.txt", "carta_postres.txt", "raciones.txt", "bocadillos.txt"]
# Ruta del archivo log
log_path = "/var/www/html/uploads/file_changes.log"

def calculate_md5(file_path):
    """Calcula el hash MD5 de un archivo."""
    hasher = hashlib.md5()
    with open(file_path, 'rb') as f:
        buf = f.read()
        hasher.update(buf)
    return hasher.hexdigest()

def update_html(file_name):
    """Actualiza el contenido HTML basado en el archivo de texto."""
    if file_name in ["carta_carnes.txt", "carta_pescados.txt", "carta_postres.txt"]:
        html_file = "/var/www/html/carta.html"
        section = file_name.split('_')[1].split('.')[0].upper()  # Extrae 'CARNES', 'PESCADOS', 'POSTRES'
    elif file_name == "raciones.txt":
        html_file = "/var/www/html/raciones.html"
        section = 'RACIONES'
    else:
        html_file = "/var/www/html/bocadillos.html"
        section = 'BOCADILLOS'

    start_marker = f"<!-- INICIO {section} -->"
    end_marker = f"<!-- FINAL {section} -->"

    with open(html_file, 'r+') as file:
        lines = file.readlines()

    start_index = next(i for i, line in enumerate(lines) if start_marker in line)
    end_index = next(i for i, line in enumerate(lines) if end_marker in line)

    # Leer los datos del archivo y agregarlos al HTML
    with open(os.path.join(directory, file_name), 'r') as file:
        items = [line.strip() for line in file if line.strip() and ':' in line]
        new_content = []
        for idx, item in enumerate(items, 1):
            element, price = item.split(':')
            new_content.append(f"    <tr>\n      <th scope=\"row\">{idx}</th>\n      <td colspan=\"2\">{element.strip()}</td>\n      <td>{price.strip()} €</td>\n    </tr>\n")

    updated_lines = lines[:start_index + 1] + new_content + lines[end_index:]
    with open(html_file, 'w') as file:
        file.writelines(updated_lines)

    # Log y recargar Apache
    with open(log_path, 'a') as log:
        log.write(f"{datetime.now()} - Actualizado {html_file}, recargando Apache.\n")
    os.system("sudo systemctl reload apache2")

def main():
    for file_name in files:
        file_path = os.path.join(directory, file_name)
        env_var_actual = f"{file_name}_hashactual"
        env_var_historic = f"{file_name}_hashhistorico"

        if os.path.exists(file_path):
            current_hash = calculate_md5(file_path)
            historic_hash = os.getenv(env_var_historic, '')

            if current_hash != historic_hash:
                # Si los hashes son diferentes, actualiza y modifica el HTML
                update_html(file_name)
                set_key(dotenv_path, env_var_historic, current_hash)  # Actualiza el hash histórico
                print(f"Actualización completada para {file_name}")
            else:
                print(f"No se detectaron cambios en {file_name}")
        else:
            print(f"Error: El archivo {file_path} no existe.")

if __name__ == "__main__":
    main()
