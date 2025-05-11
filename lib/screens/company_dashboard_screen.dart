import 'package:flutter/material.dart';
import 'manage_technicians_screen.dart';
import 'manage_clients_screen.dart';
import 'manage_cultivos_screen.dart';

class CompanyDashboardScreen extends StatelessWidget {
  const CompanyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Empresa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.engineering),
              label: const Text('Gestionar Técnicos'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManageTechniciansScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.people),
              label: const Text('Gestionar Clientes'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManageClientsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.agriculture),
              label: const Text('Gestionar Cultivos'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManageCultivosScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

const exampleClientData = {
  "nombre": "Cliente Ejemplo",
  "telefono": "600000000",
  "email": "opcional@correo.com",
  "activo": true,
  "fincas": [
    {
      "nombre": "Finca 1",
      "cultivos": [
        {
          "nombre": "Olivo",
          "variedades": [
            {
              "nombre": "Picual",
              "num_arboles": 100,
              "hectareas": 2.5
            },
            // más variedades
          ]
        },
        // más cultivos
      ]
    },
    // más fincas
  ]
};