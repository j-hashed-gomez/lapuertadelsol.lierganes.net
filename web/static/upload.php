<?php
ob_start(); // Inicia el buffering de salida

// Directorio donde se guardarán los archivos subidos
$target_dir = "/var/www/html/uploads/";
// Especifica la ruta del archivo a guardar
$target_file = $target_dir . basename($_FILES["fileToUpload"]["name"]);
$uploadOk = 1;
// Obtén la extensión del archivo
$imageFileType = strtolower(pathinfo($target_file, PATHINFO_EXTENSION));

// Verifica el tamaño del archivo (ej. no más de 5MB)
if ($_FILES["fileToUpload"]["size"] > 5000000) {
    echo "Lo siento, tu archivo es demasiado grande.";
    $uploadOk = 0;
}

// Permite ciertos formatos de archivo
if($imageFileType != "txt" ) {
    echo "Lo siento, solo archivos TXT son permitidos.";
    $uploadOk = 0;
}

// Verifica si $uploadOk se ha puesto en 0 por un error
if ($uploadOk == 0) {
    echo "Lo siento, tu archivo no fue subido.";
} else {
    if (move_uploaded_file($_FILES["fileToUpload"]["tmp_name"], $target_file)) {
        echo "El archivo ". htmlspecialchars(basename($_FILES["fileToUpload"]["name"])). " ha sido subido.";
        sleep(3); // Espera 3 segundos antes de proceder
        shell_exec('python3 /var/www/html/update.py >> /var/www/html/uploads/file_changes.log 2>&1'); // Ejecuta el script Python

        // Redirecciona al usuario
        header('Location: https://lapuertadelsol.lierganes.net/index.html');
        ob_end_flush(); // Envía el contenido del buffer y detiene el buffering
        exit();
    } else {
        echo "Lo siento, hubo un error subiendo tu archivo.";
    }
}

ob_end_flush(); // Asegura que cualquier salida se envía al final
?>
