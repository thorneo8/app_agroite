<?php
// api/login.php

// Mostrar errores para depuración
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

try {
    require_once __DIR__ . '/../config/config.php';

    if (!isset($conn) || $conn->connect_error) {
        throw new Exception('Error de conexión: ' . ($conn->connect_error ?? 'desconocido'));
    }

    $data = json_decode(file_get_contents('php://input'), true);
    $email    = trim($data['email']    ?? '');
    $password = $data['password'] ?? '';

    if ($email === '' || $password === '') {
        http_response_code(400);
        echo json_encode(['error' => 'Faltan email o password']);
        exit;
    }

    // 1) Intentamos en empresas
    $stmt = $conn->prepare("
        SELECT id, nombre, razon_social, cif, email, password_hash
        FROM empresas
        WHERE email = ?
    ");
    if (!$stmt) {
        throw new Exception('Error al preparar statement empresas: ' . $conn->error);
    }
    $stmt->bind_param('s', $email);
    if (!$stmt->execute()) {
        throw new Exception('Error al ejecutar query empresas: ' . $stmt->error);
    }
    $stmt->bind_result($e_id, $e_nombre, $e_razon, $e_cif, $e_email, $e_hash);
    if ($stmt->fetch()) {
        if (password_verify($password, $e_hash)) {
            echo json_encode([
                'id'           => $e_id,
                'nombre'       => $e_nombre,
                'razon_social' => $e_razon,
                'cif'          => $e_cif,
                'email'        => $e_email,
                'role'         => 'empresa',
            ]);
            exit;
        } else {
            http_response_code(401);
            echo json_encode(['error' => 'Contraseña incorrecta']);
            exit;
        }
    }
    $stmt->close();

    // 2) Intentamos en técnicos
    $stmt = $conn->prepare("
        SELECT id, empresa_id, nombre_apellido, email, telefono, password_hash, activo
        FROM tecnicos
        WHERE email = ?
    ");
    if (!$stmt) {
        throw new Exception('Error al preparar statement tecnicos: ' . $conn->error);
    }
    $stmt->bind_param('s', $email);
    if (!$stmt->execute()) {
        throw new Exception('Error al ejecutar query tecnicos: ' . $stmt->error);
    }
    $stmt->bind_result($t_id, $t_empresa_id, $t_nombre, $t_email, $t_telefono, $t_hash, $t_activo);
    if ($stmt->fetch()) {
        if (!$t_activo) {
            http_response_code(403);
            echo json_encode(['error' => 'Técnico desactivado']);
            exit;
        }
        if (password_verify($password, $t_hash)) {
            echo json_encode([
                'id'             => $t_id,
                'empresa_id'     => $t_empresa_id,
                'nombre_apellido'=> $t_nombre,
                'email'          => $t_email,
                'telefono'       => $t_telefono,
                'role'           => 'tecnico',
            ]);
            exit;
        } else {
            http_response_code(401);
            echo json_encode(['error' => 'Contraseña incorrecta']);
            exit;
        }
    }
    $stmt->close();

    // 3) Intentamos en clientes
    $stmt = $conn->prepare("
        SELECT id, empresa_id, tecnico_id, nombre_apellido, email, telefono, password_hash, ubicacion
        FROM clientes
        WHERE email = ?
    ");
    if (!$stmt) {
        throw new Exception('Error al preparar statement clientes: ' . $conn->error);
    }
    $stmt->bind_param('s', $email);
    if (!$stmt->execute()) {
        throw new Exception('Error al ejecutar query clientes: ' . $stmt->error);
    }
    $stmt->bind_result($c_id, $c_empresa_id, $c_tecnico_id, $c_nombre, $c_email, $c_telefono, $c_hash, $c_ubicacion);
    if ($stmt->fetch()) {
        if (password_verify($password, $c_hash)) {
            echo json_encode([
                'id'             => $c_id,
                'empresa_id'     => $c_empresa_id,
                'tecnico_id'     => $c_tecnico_id,
                'nombre_apellido'=> $c_nombre,
                'email'          => $c_email,
                'telefono'       => $c_telefono,
                'ubicacion'      => $c_ubicacion,
                'role'           => 'cliente',
            ]);
            exit;
        } else {
            http_response_code(401);
            echo json_encode(['error' => 'Contraseña incorrecta']);
            exit;
        }
    }
    $stmt->close();

    // No encontrado
    http_response_code(404);
    echo json_encode(['error' => 'Usuario no encontrado']);
    $conn->close();
}
catch (Throwable $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Excepción: ' . $e->getMessage()]);
}
