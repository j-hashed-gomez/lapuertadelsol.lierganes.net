# Utilizar la imagen oficial de Debian stable
FROM debian:stable-slim

# Establecer el directorio de trabajo en el contenedor
WORKDIR /app

# Actualizar la lista de paquetes y instalar dependencias
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Crear un entorno virtual para la aplicación Python
RUN python3 -m venv venv

# Activar el entorno virtual
ENV PATH="/app/venv/bin:$PATH"

# Copiar los archivos de la aplicación Flask al contenedor
COPY /web/static/* /app/

# Instalar las dependencias de Flask usando pip
RUN pip install --upgrade pip && pip install flask

# Exponer el puerto que utilizará la aplicación Flask
EXPOSE 5000

# Comando para ejecutar la aplicación Flask
CMD ["flask", "run", "--host=0.0.0.0"]
