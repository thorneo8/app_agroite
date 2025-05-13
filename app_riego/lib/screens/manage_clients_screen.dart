import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'client_detail_screen.dart';
import 'finca_form.dart';

class ManageClientsScreen extends StatefulWidget {
  const ManageClientsScreen({super.key});

  @override
  State<ManageClientsScreen> createState() => _ManageClientsScreenState();
}

class _ManageClientsScreenState extends State<ManageClientsScreen> {
  late Box clientsBox;

  @override
  void initState() {
    super.initState();
    clientsBox = Hive.box('clientes');
  }

  void _addCliente(String nombre) {
    clientsBox.add({
      'nombre': nombre,
      'telefono': '',
      'email': '',
      'activo': true,
      'fincas': [],
    });
    setState(() {});
  }

  void _addFinca(int index, Map<String, dynamic> finca) {
    final cliente = clientsBox.getAt(index) as Map;
    final fincas = List<Map<String, dynamic>>.from(cliente['fincas'] ?? []);
    fincas.add(finca);
    clientsBox.putAt(index, {
      ...cliente,
      'fincas': fincas,
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestionar Clientes')),
      body: ValueListenableBuilder<Box>(
        valueListenable: clientsBox.listenable(),
        builder: (context, box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('No hay clientes registrados.'));
          }
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final cliente = box.getAt(index) as Map?;
              if (cliente == null) return const SizedBox.shrink();
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(cliente['nombre'] ?? 'Sin nombre'),
                  subtitle: Text(
                    'Teléfono: ${cliente['telefono'] ?? '-'}\n'
                    'Activo: ${cliente['activo'] == true ? "Sí" : "No"}\n'
                    'Fincas: ${cliente['fincas']?.length ?? 0}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add),
                        tooltip: 'Añadir finca',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => FincaForm(
                              onSave: (finca) => _addFinca(index, finca),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ClientDetailScreen(cliente: cliente),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Añadir Cliente',
        child: const Icon(Icons.add),
        onPressed: () {
          final controller = TextEditingController();
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Nuevo Cliente'),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: 'Nombre del cliente'),
                autofocus: true,
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    _addCliente(value.trim());
                    Navigator.pop(context);
                  }
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final value = controller.text.trim();
                    if (value.isNotEmpty) {
                      _addCliente(value);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

const cultivos = [
  {
    "nombre": "Olivo",
    "variedades": ["Picual", "Arbequina", "Hojiblanca"]
  },
  {
    "nombre": "Almendro",
    "variedades": ["Marcona", "Guara"]
  }
  // ...otros cultivos
];

const exampleClient = {
  "nombre": "Cliente Ejemplo",
  "fincas": [
    {
      "nombre": "Finca 1",
      "cultivos": [
        {
          "cultivo": "Olivo", // referencia al nombre global
          "variedades": [
            {
              "variedad": "Picual", // referencia al nombre global
              "num_arboles": 100,
              "hectareas": 2.5
            }
          ]
        }
      ]
    }
  ]
};