import hashlib
import os
from datetime import datetime
from dotenv import load_dotenv, set_key

# Carga las variables de entorno desde el archivo .env
dotenv_path = "/var/www/html/uploads/.env"
load_dotenv(dotenv_path)

# Ruta donde se encuentran los archivos
directory = "/var/www/html/uploads/"
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

def main():
    changes_detected = False
    for file_name in files:
        file_path = os.path.join(directory, file_name)
        env_var_actual = f"{file_name}_hashactual"
        env_var_historic = f"{file_name}_hashhistorico"

        if os.path.exists(file_path):
            current_hash = calculate_md5(file_path)
            historic_hash = os.getenv(env_var_historic, '')

            if current_hash == historic_hash:
                with open(log_path, 'a') as log_file:
                    log_file.write(f"{datetime.now()} - No hay cambios que aplicar para {file_name}\n")
            else:
                set_key(dotenv_path, env_var_historic, current_hash)  # Actualiza el .env con el nuevo hash
                with open(log_path, 'a') as log_file:
                    log_file.write(f"{datetime.now()} - Cambios detectados y aplicados para {file_name}\n")
                changes_detected = True
        else:
            print(f"Error: El archivo {file_path} no existe.")

    if not changes_detected:
        exit()

if __name__ == "__main__":
    main()
