<?php
// listados/listar_tecnicos.php

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

require_once __DIR__ . '/../config/config.php';

// Si viene empresa_id, filtramos; si no, devolvemos todos
if (isset($_GET['empresa_id'])) {
    $empresa_id = intval($_GET['empresa_id']);
    $stmt = $conn->prepare(
        "SELECT id, empresa_id, nombre_apellido, email, telefono
         FROM tecnicos
         WHERE empresa_id = ?"
    );
    $stmt->bind_param('i', $empresa_id);
    $stmt->execute();
    $result = $stmt->get_result();
    $tecnicos = $result->fetch_all(MYSQLI_ASSOC);
}
else {
    // Sin filtro, listamos todos los técnicos
    $result = $conn->query(
        "SELECT id, empresa_id, nombre_apellido, email, telefono
         FROM tecnicos"
    );
    $tecnicos = $result->fetch_all(MYSQLI_ASSOC);
}

echo json_encode($tecnicos);
$conn->close();
