<?php
$upload_dir = "/var/www/html/uploads/";
$zip_file = $upload_dir . "lapuertadelsol.zip";

// Comprime los archivos .txt en un archivo zip
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
?>
