<?php
// api/login_empresa.php

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

require_once __DIR__ . '/../config/config.php';

$data = json_decode(file_get_contents('php://input'), true);

if (empty($data['email']) || empty($data['password'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Faltan email o password']);
    exit;
}

// Buscamos el registro por email
$stmt = $conn->prepare("SELECT id, nombre, razon_social, cif, email, password_hash FROM empresas WHERE email = ?");
$stmt->bind_param('s', $data['email']);
$stmt->execute();
$result = $stmt->get_result();

if ($row = $result->fetch_assoc()) {
    if (password_verify($data['password'], $row['password_hash'])) {
        // Eliminamos el password_hash de la respuesta
        unset($row['password_hash']);
        echo json_encode($row);
    } else {
        http_response_code(401);
        echo json_encode(['error' => 'Contraseña incorrecta']);
    }
} else {
    http_response_code(404);
    echo json_encode(['error' => 'Empresa no encontrada']);
}

$conn->close();
