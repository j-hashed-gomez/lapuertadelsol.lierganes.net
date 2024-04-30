# Usar Debian stable como imagen base
FROM debian:stable-slim

# Establecer el directorio de trabajo
WORKDIR /app

# Instalar Python, pip y herramientas necesarias
RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copiar los archivos de la aplicación al directorio de trabajo
COPY . /app

# Instalar Flask
RUN pip3 install flask

# Exponer el puerto 5000 para la aplicación Flask
EXPOSE 5000

# Establecer la variable de entorno para Flask
ENV FLASK_APP=server.py
ENV FLASK_RUN_HOST=0.0.0.1

# Ejecutar la aplicación Flask cuando el contenedor inicie
CMD ["flask", "run", "--host=0.0.0.0"]

