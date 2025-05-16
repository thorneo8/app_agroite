<?php
// api/login.php

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

require_once __DIR__ . '/../config/config.php';

$data = json_decode(file_get_contents('php://input'), true);
$email    = $data['email']    ?? '';
$password = $data['password'] ?? '';

if (empty($email) || empty($password)) {
    http_response_code(400);
    echo json_encode(['error'=>'Faltan email o password']);
    exit;
}

// 1) Intentamos en empresas
$stmt = $conn->prepare("SELECT id, nombre, razon_social, cif, email, password_hash FROM empresas WHERE email=?");
$stmt->bind_param('s',$email);
$stmt->execute();
$res = $stmt->get_result();
if ($row = $res->fetch_assoc()) {
    if (password_verify($password,$row['password_hash'])) {
        unset($row['password_hash']);
        $row['role'] = 'empresa';
        echo json_encode($row);
        exit;
    } else {
        http_response_code(401);
        echo json_encode(['error'=>'Contraseña incorrecta']);
        exit;
    }
}

// 2) Intentamos en técnicos
$stmt = $conn->prepare("SELECT id, empresa_id, nombre_apellido, email, telefono, password_hash, activo FROM tecnicos WHERE email=?");
$stmt->bind_param('s',$email);
$stmt->execute();
$res = $stmt->get_result();
if ($row = $res->fetch_assoc()) {
    if (!$row['activo']) {
        http_response_code(403);
        echo json_encode(['error'=>'Técnico desactivado']);
        exit;
    }
    if (password_verify($password,$row['password_hash'])) {
        unset($row['password_hash']);
        $row['role'] = 'tecnico';
        echo json_encode($row);
        exit;
    } else {
        http_response_code(401);
        echo json_encode(['error'=>'Contraseña incorrecta']);
        exit;
    }
}

// 3) Intentamos en clientes
$stmt = $conn->prepare("SELECT id, empresa_id, tecnico_id, nombre_apellido, email, telefono, password_hash, ubicacion FROM clientes WHERE email=?");
$stmt->bind_param('s',$email);
$stmt->execute();
$res = $stmt->get_result();
if ($row = $res->fetch_assoc()) {
    if (password_verify($password,$row['password_hash'])) {
        unset($row['password_hash']);
        $row['role'] = 'cliente';
        echo json_encode($row);
        exit;
    } else {
        http_response_code(401);
        echo json_encode(['error'=>'Contraseña incorrecta']);
        exit;
    }
}

// Si no se encontró en ninguna tabla
http_response_code(404);
echo json_encode(['error'=>'Usuario no encontrado']);
$conn->close();
