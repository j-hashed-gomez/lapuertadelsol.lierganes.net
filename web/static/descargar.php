<?php
$upload_dir = "/var/www/html/uploads/";
$zip_file = $upload_dir . "lapuertadelsol.zip";

// Comprime los archivos .txt y .png en un archivo zip
$zip = new ZipArchive();
if ($zip->open($zip_file, ZipArchive::CREATE | ZipArchive::OVERWRITE) === TRUE) {
    // Busca archivos .txt y .png
    $all_files = glob($upload_dir . "*.{txt,png}", GLOB_BRACE);
    
    // Agrega todos los archivos encontrados al ZIP
    foreach ($all_files as $file) {
        $zip->addFile($file, basename($file));
    }

    // Cierra el archivo ZIP
    $zip->close();
} else {
    echo "Lo siento, no se pudo abrir el archivo zip para su creación.";
    exit();
}

// Descarga el archivo zip
if (file_exists($zip_file)) {
    header('Content-Description: File Transfer');
    header('Content-Type: application/zip');
    header('Content-Disposition: attachment; filename="' . basename($zip_file) . '"');
    header('Content-Length: ' . filesize($zip_file));
    readfile($zip_file);

    // Borra el archivo zip después de ser descargado
    unlink($zip_file);
    exit();
} else {
    echo "Lo siento, no se pudo encontrar el archivo zip para la descarga.";
}
?>
