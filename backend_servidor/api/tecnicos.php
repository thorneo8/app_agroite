<?php
// api/tecnicos.php

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

require_once __DIR__ . '/../config/config.php';

try {
    // Si recibimos empresa_id, filtramos; si no, devolvemos todos
    if (isset($_GET['empresa_id'])) {
        $empresa_id = intval($_GET['empresa_id']);
        $stmt = $conn->prepare("
            SELECT id, nombre_apellido, email, telefono
            FROM tecnicos
            WHERE empresa_id = ?
        ");
        if (!$stmt) {
            throw new Exception('Error al preparar query: ' . $conn->error);
        }
        $stmt->bind_param('i', $empresa_id);
        if (!$stmt->execute()) {
            throw new Exception('Error al ejecutar query: ' . $stmt->error);
        }
        $stmt->bind_result($id, $nombre, $email, $telefono);

        $tecnicos = [];
        while ($stmt->fetch()) {
            $tecnicos[] = [
                'id'             => $id,
                'nombre_apellido'=> $nombre,
                'email'          => $email,
                'telefono'       => $telefono,
            ];
        }
        $stmt->close();
    } else {
        // Sin filtro: listamos todos
        $result = $conn->query("
            SELECT id, nombre_apellido, email, telefono
            FROM tecnicos
        ");
        if (!$result) {
            throw new Exception('Error al consultar tecnicos: ' . $conn->error);
        }
        $tecnicos = [];
        while ($row = $result->fetch_assoc()) {
            $tecnicos[] = $row;
        }
    }

    echo json_encode($tecnicos);
    $conn->close();
} catch (Throwable $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}
