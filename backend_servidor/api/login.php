<?php
// Mostrar errores en depuración
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
header("Access-Control-Allow-Methods: POST");

include_once("../config/config.php");

// 1. Sólo POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['status'=>'error','message'=>'Método no permitido']);
    exit;
}

// 2. Conexión OK?
if (!isset($conn) || $conn->connect_errno) {
    http_response_code(500);
    echo json_encode([
      'status'=>'error',
      'message'=>'Error en conexión DB: ' . ($conn->connect_error ?? 'desconocido')
    ]);
    exit;
}

// 3. Leer JSON
$input = json_decode(file_get_contents('php://input'), true);
$usuario  = trim($input['usuario']  ?? '');
$password = trim($input['password'] ?? '');
if (!$usuario || !$password) {
    http_response_code(400);
    echo json_encode(['status'=>'error','message'=>'Faltan campos']);
    exit;
}

// 4. Preparar consulta
$stmt = $conn->prepare(
    "SELECT id, nombre, password 
       FROM admin_supremo 
      WHERE nombre = ?"
);
if (!$stmt) {
    http_response_code(500);
    echo json_encode(['status'=>'error','message'=>'Error al preparar consulta']);
    exit;
}
$stmt->bind_param("s", $usuario);

// 5. Ejecutar y enlazar resultados
if (!$stmt->execute()) {
    http_response_code(500);
    echo json_encode(['status'=>'error','message'=>'Error al ejecutar consulta']);
    exit;
}
$stmt->bind_result($id, $nombre_db, $hashed_password);

// 6. Comprobar filas
if ($stmt->fetch()) {
    // 7. Verificar contraseña
    if (password_verify($password, $hashed_password)) {
        echo json_encode([
            'status' => 'success',
            'user'   => ['id'=>$id,'nombre'=>$nombre_db]
        ]);
    } else {
        http_response_code(401);
        echo json_encode(['status'=>'error','message'=>'Contraseña incorrecta']);
    }
} else {
    http_response_code(404);
    echo json_encode(['status'=>'error','message'=>'Usuario no encontrado']);
}

$stmt->close();
