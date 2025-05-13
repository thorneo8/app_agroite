import 'package:flutter/material.dart';

class ClientDetailScreen extends StatelessWidget {
  final Map cliente;
  const ClientDetailScreen({super.key, required this.cliente});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(cliente['nombre'] ?? 'Detalle del Cliente')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Teléfono: ${cliente['telefono'] ?? "-"}'),
            Text('Email: ${cliente['email'] ?? "-"}'),
            Text('Activo: ${cliente['activo'] == true ? "Sí" : "No"}'),
            // Aquí puedes mostrar fincas, cultivos, etc.
          ],
        ),
      ),
    );
  }
}