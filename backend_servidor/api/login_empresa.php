<?php
// api/login_empresa.php

// 1) Activar errores para depuración
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

try {
    require_once __DIR__ . '/../config/config.php';

    // Verificamos que $conn exista
    if (!isset($conn) || $conn->connect_error) {
        throw new Exception('Error de conexión: ' . ($conn->connect_error ?? 'desconocido'));
    }

    $data = json_decode(file_get_contents('php://input'), true);
    $email    = $data['email']    ?? '';
    $password = $data['password'] ?? '';

    if (empty($email) || empty($password)) {
        http_response_code(400);
        echo json_encode(['error' => 'Faltan email o password']);
        exit;
    }

    // Preparamos consulta
    $stmt = $conn->prepare("SELECT id, nombre, razon_social, cif, email, password_hash FROM empresas WHERE email = ?");
    if (!$stmt) {
        throw new Exception('Error al preparar statement: ' . $conn->error);
    }
    $stmt->bind_param('s', $email);
    if (!$stmt->execute()) {
        throw new Exception('Error al ejecutar query: ' . $stmt->error);
    }
    $result = $stmt->get_result();
    if ($row = $result->fetch_assoc()) {
        if (password_verify($password, $row['password_hash'])) {
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
    $stmt->close();
    $conn->close();
}
catch (Throwable $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Excepción: ' . $e->getMessage()]);
}
