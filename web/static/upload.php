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

        // Comprime los archivos .txt en un archivo zip
        $zip_file = $upload_dir . "lapuertadelsol.zip";
        $zip = new ZipArchive();
        if ($zip->open($zip_file, ZipArchive::CREATE | ZipArchive::OVERWRITE) === TRUE) {
            $txt_files = glob($upload_dir . "*.txt");
            foreach ($txt_files as $file) {
                $zip->addFile($file, basename($file));
            }
            $zip->close();
        }

        // Descarga el archivo zip
        if (file_exists($zip_file)) {
            header('Content-Description: File Transfer');
            header('Content-Type: application/zip');
            header('Content-Disposition: attachment; filename="'.basename($zip_file).'"');
            header('Content-Length: ' . filesize($zip_file));
            readfile($zip_file);
            
            // Borra el archivo zip después de ser descargado
            unlink($zip_file);
            exit();
        } else {
            echo "Lo siento, no se pudo crear el archivo zip.";
        }
    } else {
        echo "Lo siento, hubo un error subiendo tu archivo.";
    }
}

ob_end_flush(); // Asegura que cualquier salida se envía al final
?>
