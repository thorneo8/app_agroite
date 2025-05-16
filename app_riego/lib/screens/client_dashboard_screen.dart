// lib/screens/client_dashboard_screen.dart

import 'package:flutter/material.dart';

class ClientDashboardScreen extends StatelessWidget {
  final Map<String, dynamic> clientData;

  const ClientDashboardScreen({super.key, required this.clientData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido ${clientData['nombre_apellido'] ?? clientData['email']}'),
      ),
      body: Center(
        child: Text(
          'Este es tu espacio, Cliente.\n\n'
          'ID: ${clientData['id']}\n'
          'Email: ${clientData['email']}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
