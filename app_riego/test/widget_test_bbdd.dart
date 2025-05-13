import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:app_riego/services/database_service.dart';

void main() {
  setUpAll(() async {
    // Inicializa Hive en modo test
    await Hive.initFlutter();
    await Hive.openBox('empresas');
  });

  tearDownAll(() async {
    await Hive.box('empresas').clear();
    await Hive.close();
  });

  test('Se puede insertar y leer empresas en la base de datos', () async {
    final db = DatabaseService();

    // Inserta una empresa de prueba
    await db.insertEmpresa({
      'nombre': 'Empresa Test',
      'email': 'test@empresa.com',
      'telefono': '123456789',
      'password': 'secreto',
    });

    // Lee las empresas
    final empresas = await db.getEmpresas();

    // Comprueba que hay al menos una empresa y que los datos coinciden
    expect(empresas.isNotEmpty, true);
    expect(empresas.last['nombre'], 'Empresa Test');
    expect(empresas.last['email'], 'test@empresa.com');
  });
}