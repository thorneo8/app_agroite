<?php
// Configuración de conexión a la base de datos
$host = 'localhost';
$user = 'agroqmnv_app';
$password = 'vz)jOWf0yo4e';
$db = 'agroqmnv_agroiteapp';

// Crear conexión
$conn = new mysqli($host, $user, $password, $db);

// Verificar conexión
if ($conn->connect_error) {
    die("Conexión fallida: " . $conn->connect_error);
}

// Establecer codificación de caracteres
$conn->set_charset("utf8");
?>
