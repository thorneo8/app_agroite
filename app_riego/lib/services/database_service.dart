import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DatabaseService {
  static const String _baseUrl = 'https://app.agroite.com/api';

  // Cajas Hive para almacenamiento offline
  final Box empresasBox = Hive.box('empresas');
  final Box tecnicosBox = Hive.box('tecnicos');
  // Puedes abrir más cajas según necesites: clientes, cultivos, etc.

  /// Registra una nueva empresa en el servidor y la guarda localmente en Hive.
  Future<Map<String, dynamic>> registerEmpresa({
    required String nombre,
    required String email,
    String? telefono,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/register_empresa.php');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': nombre,
        'email': email,
        'telefono': telefono ?? '',
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['status'] == 'success') {
        final empresa = Map<String, dynamic>.from(data['empresa']);
        // Guardar en Hive
        await empresasBox.add(empresa);
        return empresa;
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Error HTTP ${response.statusCode}');
    }
  }

  /// Inicia sesión de empresa en el servidor.
  /// Devuelve los datos del usuario si tiene éxito.
  Future<Map<String, dynamic>> loginEmpresa({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/login_empresa.php');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['status'] == 'success') {
        final user = Map<String, dynamic>.from(data['user']);
        // Opcional: guardar en Hive
        return user;
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Error HTTP ${response.statusCode}');
    }
  }

  /// Inicia sesión de técnico en el servidor y lo guarda localmente.
  Future<Map<String, dynamic>> loginTecnico({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/login_tecnico.php');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['status'] == 'success') {
        final user = Map<String, dynamic>.from(data['user']);
        // Guardar en Hive
        await tecnicosBox.add(user);
        return user;
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Error HTTP ${response.statusCode}');
    }
  }

  /// Retorna todas las empresas almacenadas offline.
  Future<List<Map<String, dynamic>>> getEmpresas() async {
    return empresasBox.values.cast<Map<String, dynamic>>().toList();
  }

  /// Retorna todos los técnicos almacenados offline.
  Future<List<Map<String, dynamic>>> getTecnicos() async {
    return tecnicosBox.values.cast<Map<String, dynamic>>().toList();
  }
}
