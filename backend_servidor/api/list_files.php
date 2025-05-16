<?php
// app.agroite.com/api/list_files.php

// Cabecera para que se vea como texto plano
header('Content-Type: text/plain');

echo "Archivos en " . __DIR__ . ":\n\n";
$files = scandir(__DIR__);
foreach ($files as $f) {
    echo " - $f\n";
}
