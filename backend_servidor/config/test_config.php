<?php
// config/test_config.php

require_once __DIR__ . '/../config/config.php';

// Verificamos si la conexión existe y no tiene errores
if (isset($conn) && $conn->ping()) {
    echo "Conexión a la base de datos: OK";
} else {
    echo "Error de conexión: " . ($conn->connect_error ?? 'desconocido');
}
?>
