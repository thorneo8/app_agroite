// lib/models/empresa.dart

import 'package:hive/hive.dart';
part 'empresa.g.dart';

@HiveType(typeId: 0)
class Empresa {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String nombre;

  @HiveField(2)
  final String razonSocial;

  @HiveField(3)
  final String cif;

  @HiveField(4)
  final String email;

  Empresa({
    required this.id,
    required this.nombre,
    required this.razonSocial,
    required this.cif,
    required this.email,
  });

  factory Empresa.fromJson(Map<String, dynamic> json) => Empresa(
        id: json['id'],
        nombre: json['nombre'],
        razonSocial: json['razon_social'],
        cif: json['cif'],
        email: json['email'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'razon_social': razonSocial,
        'cif': cif,
        'email': email,
      };
}
