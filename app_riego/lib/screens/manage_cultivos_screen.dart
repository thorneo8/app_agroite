import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ManageCultivosScreen extends StatefulWidget {
  const ManageCultivosScreen({super.key});

  @override
  State<ManageCultivosScreen> createState() => _ManageCultivosScreenState();
}

class _ManageCultivosScreenState extends State<ManageCultivosScreen> {
  late Box cultivosBox;
  final _cultivoController = TextEditingController();
  final Map<int, TextEditingController> _variedadControllers = {};

  @override
  void initState() {
    super.initState();
    cultivosBox = Hive.box('cultivos');
  }

  @override
  void dispose() {
    _cultivoController.dispose();
    for (final controller in _variedadControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addCultivo() {
    final nombre = _cultivoController.text.trim();
    if (nombre.isEmpty) return;
    final existe = cultivosBox.values.any((c) => c['nombre'] == nombre);
    if (existe) return;
    cultivosBox.add({'nombre': nombre, 'variedades': <String>[]});
    _cultivoController.clear();
    setState(() {});
  }

  void _addVariedad(int index) {
    final controller = _variedadControllers[index]!;
    final variedad = controller.text.trim();
    if (variedad.isEmpty) return;
    final cultivo = cultivosBox.getAt(index) as Map;
    final variedades = List<String>.from(cultivo['variedades'] ?? []);
    if (variedades.contains(variedad)) return;
    variedades.add(variedad);
    cultivosBox.putAt(index, {'nombre': cultivo['nombre'], 'variedades': variedades});
    controller.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestionar Cultivos y Variedades')),
      body: ValueListenableBuilder<Box>(
        valueListenable: cultivosBox.listenable(),
        builder: (context, box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('No hay cultivos registrados.'));
          }
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final cultivo = box.getAt(index) as Map?;
              if (cultivo == null) return const SizedBox.shrink();
              final variedades = List<String>.from(cultivo['variedades'] ?? []);
              _variedadControllers.putIfAbsent(index, () => TextEditingController());
              return Card(
                margin: const EdgeInsets.all(8),
                child: ExpansionTile(
                  title: Text(cultivo['nombre'] ?? 'Sin nombre'),
                  children: [
                    ...variedades.map((v) => ListTile(
                          title: Text(v),
                        )),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _variedadControllers[index],
                              decoration: const InputDecoration(
                                labelText: 'Añadir variedad',
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => _addVariedad(index),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Añadir Cultivo',
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Nuevo Cultivo'),
              content: TextField(
                controller: _cultivoController,
                decoration: const InputDecoration(labelText: 'Nombre del cultivo'),
                autofocus: true,
                onSubmitted: (_) {
                  _addCultivo();
                  Navigator.pop(context);
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _cultivoController.clear();
                    Navigator.pop(context);
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _addCultivo();
                    Navigator.pop(context);
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

// Puedes poner esto en un dialog, pantalla o widget aparte
class FincaForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  const FincaForm({super.key, required this.onSave});

  @override
  State<FincaForm> createState() => _FincaFormState();
}

class _FincaFormState extends State<FincaForm> {
  String? nombreFinca;
  String? cultivoSeleccionado;
  String? variedadSeleccionada;
  int? numArboles;
  double? hectareas;

  @override
  Widget build(BuildContext context) {
    final cultivosBox = Hive.box('cultivos');
    final cultivos = cultivosBox.values.toList();

    List<String> variedades = [];
    if (cultivoSeleccionado != null) {
      final cultivo = cultivos.firstWhere(
        (c) => c['nombre'] == cultivoSeleccionado,
        orElse: () => null,
      );
      if (cultivo != null) {
        variedades = List<String>.from(cultivo['variedades'] ?? []);
      }
    }

    return AlertDialog(
      title: const Text('Añadir Finca'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Nombre de la finca'),
              onChanged: (v) => nombreFinca = v,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Cultivo'),
              items: cultivos
                  .map<DropdownMenuItem<String>>(
                      (c) => DropdownMenuItem(value: c['nombre'], child: Text(c['nombre'])))
                  .toList(),
              value: cultivoSeleccionado,
              onChanged: (value) {
                setState(() {
                  cultivoSeleccionado = value;
                  variedadSeleccionada = null;
                });
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Variedad'),
              items: variedades
                  .map<DropdownMenuItem<String>>(
                      (v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              value: variedadSeleccionada,
              onChanged: (value) {
                setState(() {
                  variedadSeleccionada = value;
                });
              },
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(labelText: 'Número de árboles'),
              keyboardType: TextInputType.number,
              onChanged: (v) => numArboles = int.tryParse(v),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(labelText: 'Hectáreas'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) => hectareas = double.tryParse(v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (nombreFinca != null &&
                cultivoSeleccionado != null &&
                variedadSeleccionada != null) {
              widget.onSave({
                'nombre': nombreFinca,
                'cultivo': cultivoSeleccionado,
                'variedad': variedadSeleccionada,
                'num_arboles': numArboles ?? 0,
                'hectareas': hectareas ?? 0.0,
              });
              Navigator.pop(context);
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}