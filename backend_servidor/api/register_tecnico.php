<?php
// api/register_tecnico.php

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

require_once __DIR__ . '/../config/config.php';

$data = json_decode(file_get_contents('php://input'), true);

if (
    empty($data['empresa_id']) ||
    empty($data['nombre_apellido']) ||
    empty($data['email']) ||
    empty($data['telefono']) ||
    empty($data['password'])
) {
    http_response_code(400);
    echo json_encode(['error' => 'Faltan datos obligatorios']);
    exit;
}

$stmt = $conn->prepare(
    "INSERT INTO tecnicos (empresa_id, nombre_apellido, email, telefono, password_hash)
     VALUES (?, ?, ?, ?, ?)"
);
$hash = password_hash($data['password'], PASSWORD_BCRYPT);
$stmt->bind_param(
    'issss',
    $data['empresa_id'],
    $data['nombre_apellido'],
    $data['email'],
    $data['telefono'],
    $hash
);

if ($stmt->execute()) {
    http_response_code(201);
    echo json_encode(['success' => true, 'id' => $stmt->insert_id]);
} else {
    http_response_code(500);
    echo json_encode(['error' => $stmt->error]);
}

$conn->close();
