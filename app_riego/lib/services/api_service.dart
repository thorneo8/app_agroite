// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:app_riego/models/empresa.dart';

class ApiService {
  final String baseUrl = 'https://app.agroite.com/api';
  late final Box<Empresa> empresaBox;

  ApiService() {
    empresaBox = Hive.box<Empresa>('empresas');
  }

  Future<List<Empresa>> fetchEmpresas() async {
    try {
      final resp = await http.get(Uri.parse('$baseUrl/empresas.php'));
      if (resp.statusCode == 200) {
        final List data = jsonDecode(resp.body);
        final list = data.map((e) => Empresa.fromJson(e)).toList();
        await empresaBox.clear();
        for (var e in list) {
          empresaBox.put(e.id, e);
        }
        // Si la lista está vacía, se devuelve la lista de Hive
        return list;
      }
      throw Exception('Error ${resp.statusCode}');
    } catch (_) {
      return empresaBox.values.toList();
    }
  }

  Future<Empresa> createEmpresa({
    required String nombre,
    String razonSocial = '',
    String cif = '',
    required String email,
    required String password,
  }) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/register_empresa.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': nombre,
        'razon_social': razonSocial,
        'cif': cif,
        'email': email,
        'password': password,
      }),
    );
    if (resp.statusCode == 201) {
      final d = jsonDecode(resp.body);
      final emp = Empresa(
        id: d['id'],
        nombre: nombre,
        razonSocial: razonSocial,
        cif: cif,
        email: email,
      );
      empresaBox.put(emp.id, emp);
      return emp;
    }
    throw Exception('Error ${resp.statusCode}');
  }

  Future<Map<String, dynamic>> loginGeneral({
    required String email,
    required String password,
  }) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/login.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (resp.statusCode == 200 && resp.body.isNotEmpty) {
      return jsonDecode(resp.body);
    }
    final m = resp.body.isNotEmpty
        ? jsonDecode(resp.body)['error']
        : 'Sin respuesta JSON';
    throw Exception(m);
  }

  /// <-- NUEVO: crear técnico
  Future<int> createTecnico({
    required int empresaId,
    required String nombreApellido,
    required String email,
    required String telefono,
  }) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/register_tecnico.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'empresa_id': empresaId,
        'nombre_apellido': nombreApellido,
        'email': email,
        'telefono': telefono,
      }),
    );
    if (resp.statusCode == 201) {
      final d = jsonDecode(resp.body);
      return d['id'] as int;
    }
    final err = jsonDecode(resp.body)['error'] ?? resp.body;
    throw Exception('Error al crear técnico: $err');
  }

  /// <-- NUEVO: listar técnicos (opc)
  Future<List<Map<String, dynamic>>> fetchTecnicos({int? empresaId}) async {
    final uri = empresaId == null
        ? Uri.parse('$baseUrl/tecnicos.php')
        : Uri.parse('$baseUrl/tecnicos.php?empresa_id=$empresaId');
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(resp.body));
    }
    throw Exception('Error al cargar técnicos: ${resp.statusCode}');
  }
    /// 4) Fijar contraseña de técnico (primera vez)
  Future<void> setTechnicianPassword({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/set_password_tecnico.php');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (resp.statusCode == 200) {
      final j = jsonDecode(resp.body);
      if (j['success'] == true) return;
      throw Exception(j['error'] ?? 'Error desconocido');
    } else {
      final j = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
      throw Exception(j['error'] ?? 'Error ${resp.statusCode}');
    }
  }
}
