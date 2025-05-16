// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'empresa.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EmpresaAdapter extends TypeAdapter<Empresa> {
  @override
  final int typeId = 0;

  @override
  Empresa read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Empresa(
      id: fields[0] as int,
      nombre: fields[1] as String,
      razonSocial: fields[2] as String,
      cif: fields[3] as String,
      email: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Empresa obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.razonSocial)
      ..writeByte(3)
      ..write(obj.cif)
      ..writeByte(4)
      ..write(obj.email);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmpresaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
