import 'package:hive/hive.dart';

class DatabaseService {
  final Box empresasBox = Hive.box('empresas');

  Future<void> insertEmpresa(Map<String, dynamic> empresa) async {
    await empresasBox.add(empresa);
  }

  Future<List<Map<String, dynamic>>> getEmpresas() async {
    return empresasBox.values.cast<Map<String, dynamic>>().toList();
  }
}