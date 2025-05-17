<?php
// api/set_password_tecnico.php

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

require_once __DIR__ . '/../config/config.php';

$data = json_decode(file_get_contents('php://input'), true);
$email    = trim($data['email']    ?? '');
$password = $data['password'] ?? '';

if ($email === '' || $password === '') {
    http_response_code(400);
    echo json_encode(['error'=>'Faltan email o password']);
    exit;
}

// Verificar que el email existe y está activo
$stmt = $conn->prepare("SELECT id, activo FROM tecnicos WHERE email = ?");
$stmt->bind_param('s',$email);
$stmt->execute();
$stmt->bind_result($id, $activo);
if (!$stmt->fetch()) {
    http_response_code(404);
    echo json_encode(['error'=>'Técnico no encontrado']);
    exit;
}
if (!$activo) {
    http_response_code(403);
    echo json_encode(['error'=>'Técnico desactivado']);
    exit;
}
$stmt->close();

// Actualizar el hash
$hash = password_hash($password, PASSWORD_BCRYPT);
$stmt = $conn->prepare("UPDATE tecnicos SET password_hash = ? WHERE id = ?");
$stmt->bind_param('si', $hash, $id);
if ($stmt->execute()) {
    echo json_encode(['success'=>true]);
} else {
    http_response_code(500);
    echo json_encode(['error'=>$stmt->error]);
}
$conn->close();
