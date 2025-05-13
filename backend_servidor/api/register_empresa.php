<?php
// Muestra errores mientras depuras
ini_set('display_errors', 1);
error_reporting(E_ALL);

// Permitir Flutter Web y definir JSON
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
header("Access-Control-Allow-Methods: POST");

// Incluir conexión
include_once("../config/config.php");

// 1) Solo POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['status'=>'error','message'=>'Método no permitido']);
    exit;
}

// 2) Leer JSON de entrada
$input = json_decode(file_get_contents('php://input'), true);
$nombre   = trim($input['nombre']   ?? '');
$email    = trim($input['email']    ?? '');
$telefono = trim($input['telefono'] ?? '');
$password = trim($input['password'] ?? '');

// 3) Validar campos
if (!$nombre || !$email || !$password) {
    http_response_code(400);
    echo json_encode(['status'=>'error','message'=>'Faltan campos obligatorios']);
    exit;
}

// 4) Hashear contraseña
$password_hash = password_hash($password, PASSWORD_DEFAULT);

// 5) Preparar INSERT
$stmt = $conn->prepare("
    INSERT INTO empresas (nombre, email, telefono, password_hash)
    VALUES (?, ?, ?, ?)
");
if (!$stmt) {
    http_response_code(500);
    echo json_encode(['status'=>'error','message'=>'Error al preparar la consulta']);
    exit;
}
$stmt->bind_param("ssss", $nombre, $email, $telefono, $password_hash);

// 6) Ejecutar y manejar duplicados
if (!$stmt->execute()) {
    if ($conn->errno === 1062) {
        http_response_code(409);
        echo json_encode(['status'=>'error','message'=>'El email ya está registrado']);
    } else {
        http_response_code(500);
        echo json_encode(['status'=>'error','message'=>'Error al insertar empresa']);
    }
    exit;
}

// 7) Responder éxito
$newId = $stmt->insert_id;
echo json_encode([
    'status'  => 'success',
    'empresa' => [
        'id'       => $newId,
        'nombre'   => $nombre,
        'email'    => $email,
        'telefono' => $telefono
    ]
]);

$stmt->close();
?>
