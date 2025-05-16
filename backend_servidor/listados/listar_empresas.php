<?php
// listados/listar_empresas.php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

require_once __DIR__ . '/../config/config.php';

$result = $conn->query("SELECT id, nombre, razon_social, cif, email FROM empresas");
$empresas = $result->fetch_all(MYSQLI_ASSOC);
echo json_encode($empresas);

$conn->close();
