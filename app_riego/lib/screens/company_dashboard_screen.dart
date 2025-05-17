// lib/screens/company_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_riego/models/empresa.dart';
import 'package:app_riego/services/api_service.dart';
import 'package:app_riego/screens/manage_technicians_screen.dart';

class CompanyDashboardScreen extends StatefulWidget {
  final Empresa empresa;
  const CompanyDashboardScreen({super.key, required this.empresa});

  @override
  State<CompanyDashboardScreen> createState() => _CompanyDashboardScreenState();
}

class _CompanyDashboardScreenState extends State<CompanyDashboardScreen> {
  late Future<List<Map<String, dynamic>>> _tecnicosFuture;

  @override
  void initState() {
    super.initState();
    final api = Provider.of<ApiService>(context, listen: false);
    _tecnicosFuture = api.fetchTecnicos(empresaId: widget.empresa.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard: ${widget.empresa.nombre}'),
      ),
      body: Column(
        children: [
          // Sección de técnicos
          ListTile(
            title: const Text('Técnicos'),
            trailing: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                // Aquí pasamos el empresaId al constructor
                final nuevoId = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ManageTechniciansScreen(
                      empresaId: widget.empresa.id,
                    ),
                  ),
                );
                if (nuevoId != null) {
                  // Si se ha creado uno, recargamos la lista
                  setState(() {
                    _tecnicosFuture = Provider.of<ApiService>(context, listen: false)
                        .fetchTecnicos(empresaId: widget.empresa.id);
                  });
                }
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _tecnicosFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final tecnicos = snapshot.data!;
                if (tecnicos.isEmpty) {
                  return const Center(child: Text('No hay técnicos aún'));
                }
                return ListView.builder(
                  itemCount: tecnicos.length,
                  itemBuilder: (context, index) {
                    final t = tecnicos[index];
                    return ListTile(
                      title: Text(t['nombre_apellido'] ?? 'Sin nombre'),
                      subtitle: Text(t['email'] ?? ''),
                    );
                  },
                );
              },
            ),
          ),

          // Si también quieres mostrar clientes, descomenta:
          // ListTile(... 'Clientes' ...),
          // Expanded(FutureBuilder(... _clientesFuture ...)),
        ],
      ),
    );
  }
}
