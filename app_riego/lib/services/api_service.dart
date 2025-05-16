// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:app_riego/models/empresa.dart';

class ApiService {
  // Ruta base de tu API
  final String baseUrl = 'https://app.agroite.com/api';

  // Caja Hive para Empresas
  late final Box<Empresa> empresaBox;

  ApiService() {
    empresaBox = Hive.box<Empresa>('empresas');
  }

  /// 1) Obtener lista de empresas (online / offline)
  Future<List<Empresa>> fetchEmpresas() async {
    try {
      final uri = Uri.parse('$baseUrl/empresas.php');
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final List data = jsonDecode(resp.body);
        final empresas = data.map((e) => Empresa.fromJson(e)).toList();
        // Sincronizar local
        await empresaBox.clear();
        for (var emp in empresas) {
          empresaBox.put(emp.id, emp);
        }
        return empresas;
      } else {
        throw Exception('Error al cargar empresas: ${resp.statusCode}');
      }
    } catch (_) {
      // Si falla o estamos offline, devolvemos lo de Hive
      return empresaBox.values.toList();
    }
  }

  /// 2) Crear nueva empresa (siempre online)
  Future<Empresa> createEmpresa({
    required String nombre,
    String razonSocial = '',
    String cif = '',
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/register_empresa.php');
    final resp = await http.post(
      uri,
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
      final data = jsonDecode(resp.body);
      final emp = Empresa(
        id: data['id'],
        nombre: nombre,
        razonSocial: razonSocial,
        cif: cif,
        email: email,
      );
      empresaBox.put(emp.id, emp);
      return emp;
    } else {
      throw Exception('Error al crear empresa: ${resp.statusCode}');
    }
  }

  /// 3) Iniciar sesión de empresa
  Future<Empresa> loginEmpresa({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/login_empresa.php');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      final emp = Empresa.fromJson(data);
      // Guardar o actualizar en Hive
      empresaBox.put(emp.id, emp);
      return emp;
    } else {
      final errorMsg = jsonDecode(resp.body)['error'] ?? 'Error ${resp.statusCode}';
      throw Exception(errorMsg);
    }
  }

  /// 4) Login unificado
  Future<Map<String, dynamic>> loginGeneral({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/login.php');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (resp.statusCode == 200) {
      // Devolvemos todo el JSON: id, role, y demás campos
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } else {
      final err = jsonDecode(resp.body)['error'] ?? 'Error ${resp.statusCode}';
      throw Exception(err);
    }
  }
}
