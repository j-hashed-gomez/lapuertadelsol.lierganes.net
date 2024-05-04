<?php
ob_start(); // Inicia el buffering de salida

// Directorio donde se guardarán los archivos subidos
$upload_dir = "/var/www/html/uploads/";
// Ruta del archivo a guardar
$target_file = $upload_dir . basename($_FILES["fileToUpload"]["name"]);
$uploadOk = 1;
// Obtén la extensión del archivo
$file_extension = strtolower(pathinfo($target_file, PATHINFO_EXTENSION));

// Verifica el tamaño del archivo (ej. no más de 5MB)
if ($_FILES["fileToUpload"]["size"] > 5000000) {
    echo "Lo siento, tu archivo es demasiado grande.";
    $uploadOk = 0;
}

// Permite ciertos formatos de archivo
if ($file_extension != "txt") {
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

        // Ejecuta el script Python
        shell_exec('python3 /var/www/html/update.py >> /var/www/html/uploads/file_changes.log 2>&1');
    } else {
        echo "Lo siento, hubo un error subiendo tu archivo.";
    }
}

ob_end_flush(); // Asegura que cualquier salida se envía al final
?>

<!DOCTYPE html>
<html>
<head>
    <title>Subir y Descargar</title>
</head>
<body>
    <h2>Subir Archivo</h2>
    <form action="" method="post" enctype="multipart/form-data">
        Seleccione un archivo .txt para subir:
        <input type="file" name="fileToUpload" id="fileToUpload">
        <input type="submit" value="Subir Archivo" name="submit">
    </form>
    
    <?php if (file_exists($upload_dir . "lapuertadelsol.zip")): ?>
        <h2>Descargar Archivo Comprimido</h2>
        <form action="descargar.php" method="post">
            <input type="submit" value="Descargar" name="download">
        </form>
    <?php endif; ?>
</body>
</html>
