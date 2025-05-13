import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

final logger = Logger();

/// Función para hacer login desde la app Flutter
Future<void> loginSupremo(String usuario, String password) async {
  const String apiUrl = 'https://app.agroite.com/api/login.php';

  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'usuario': usuario,
      'password': password,
    }),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = jsonDecode(response.body);

    if (data['status'] == 'success') {
      logger.i("✅ Login exitoso");
      logger.i("Usuario: ${data['user']['nombre']}");
    } else {
      logger.e("❌ Error: ${data['message']}");
    }
  } else {
    logger.e("❌ Error HTTP: ${response.statusCode}");
  }
}
