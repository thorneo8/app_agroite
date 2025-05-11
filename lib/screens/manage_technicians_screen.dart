import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class ManageTechniciansScreen extends StatefulWidget {
  const ManageTechniciansScreen({super.key});

  @override
  State<ManageTechniciansScreen> createState() => _ManageTechniciansScreenState();
}

class _ManageTechniciansScreenState extends State<ManageTechniciansScreen> {
  late Box techniciansBox;

  @override
  void initState() {
    super.initState();
    techniciansBox = Hive.box('tecnicos');
  }

  void addTechnician(String nombre, String email, String telefono, String empresaId) {
    final id = const Uuid().v4();
    final tecnico = {
      'id': id,
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'empresaId': empresaId,
      'activo': true,
      'password': null,
    };
    techniciansBox.put(id, tecnico);
    setState(() {});
  }

  void toggleActivo(String id, bool current) {
    final tecnico = Map<String, dynamic>.from(techniciansBox.get(id));
    tecnico['activo'] = !current;
    techniciansBox.put(id, tecnico);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final tecnicos = techniciansBox.toMap().values.toList().cast<Map>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Técnicos'),
      ),
      body: ListView.builder(
        itemCount: tecnicos.length,
        itemBuilder: (context, index) {
          final tecnico = tecnicos[index];
          return ListTile(
            title: Text(tecnico['nombre'] ?? ''),
            subtitle: Text(tecnico['email'] ?? ''),
            trailing: Switch(
              value: tecnico['activo'] ?? false,
              onChanged: (_) => toggleActivo(tecnico['id'], tecnico['activo']),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) {
              final nombreController = TextEditingController();
              final emailController = TextEditingController();
              final telefonoController = TextEditingController();

              return AlertDialog(
                title: const Text('Nuevo Técnico'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: nombreController, decoration: const InputDecoration(labelText: 'Nombre')),
                    TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
                    TextField(controller: telefonoController, decoration: const InputDecoration(labelText: 'Teléfono')),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      addTechnician(
                        nombreController.text,
                        emailController.text,
                        telefonoController.text,
                        'empresa-001', // Temporal
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Guardar'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}