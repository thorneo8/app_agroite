<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
header("Access-Control-Allow-Methods: POST");

include_once("../config/config.php");

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['status'=>'error','message'=>'Método no permitido']);
    exit;
}

$input = json_decode(file_get_contents('php://input'), true);
$email    = trim($input['email']    ?? '');
$password = trim($input['password'] ?? '');

if (!$email || !$password) {
    http_response_code(400);
    echo json_encode(['status'=>'error','message'=>'Faltan datos']);
    exit;
}

$stmt = $conn->prepare("SELECT id, nombre, password_hash FROM empresas WHERE email = ?");
if (!$stmt) {
    http_response_code(500);
    echo json_encode(['status'=>'error','message'=>'Error al preparar la consulta']);
    exit;
}
$stmt->bind_param("s", $email);
$stmt->execute();
$stmt->bind_result($id, $nombre, $hash);

if ($stmt->fetch()) {
    if (password_verify($password, $hash)) {
        echo json_encode([
            'status'=>'success',
            'user' => [
                'id'     => $id,
                'nombre' => $nombre,
                'email'  => $email
            ]
        ]);
    } else {
        http_response_code(401);
        echo json_encode(['status'=>'error','message'=>'Contraseña incorrecta']);
    }
} else {
    http_response_code(404);
    echo json_encode(['status'=>'error','message'=>'Empresa no encontrada']);
}

$stmt->close();
?>
