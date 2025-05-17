import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_riego/services/api_service.dart';
import 'package:app_riego/screens/register_technician_screen.dart';

class ManageTechniciansScreen extends StatefulWidget {
  final int empresaId;
  const ManageTechniciansScreen({super.key, required this.empresaId});

  @override
  State<ManageTechniciansScreen> createState() =>
      _ManageTechniciansScreenState();
}

class _ManageTechniciansScreenState extends State<ManageTechniciansScreen> {
  late Future<List<Map<String, dynamic>>> _tecnicosFuture;

  @override
  void initState() {
    super.initState();
    _loadTecnicos();
  }

  void _loadTecnicos() {
    _tecnicosFuture = Provider.of<ApiService>(context, listen: false)
        .fetchTecnicos(empresaId: widget.empresaId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestionar Técnicos')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
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
            itemBuilder: (context, i) {
              final t = tecnicos[i];
              return ListTile(
                title: Text(t['nombre_apellido'] ?? 'Sin nombre'),
                subtitle: Text(t['email'] ?? ''),
                trailing: Switch(
                  value: t['activo'] == true,
                  onChanged: (_) {
                    // Si quieres manejar activo/inactivo, hazlo por API y luego recarga:
                    // await api.toggleTecnicoActivo(...);
                    // _loadTecnicos(); setState((){});
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navegamos a la pantalla de crear técnico y esperamos el nuevo ID
          final nuevoId = await Navigator.push<String>(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  RegisterTechnicianScreen(empresaId: widget.empresaId),
            ),
          );
          if (nuevoId != null) {
            // Tras volver, recargamos la lista
            _loadTecnicos();
            setState(() {});
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
