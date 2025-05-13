<?php
include_once("../config/config.php");

if ($conn && !$conn->connect_error) {
    echo "✅ Conexión exitosa a la base de datos.";
} else {
    echo "❌ Error al conectar a la base de datos: " . $conn->connect_error;
}
?>
