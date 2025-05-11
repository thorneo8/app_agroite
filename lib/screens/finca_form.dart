import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

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

class FincaScreen extends StatelessWidget {
  const FincaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fincas'),
      ),
      body: const Center(
        child: Text('Lista de fincas'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => FincaForm(
              onSave: (finca) {
                // Añade la finca al cliente y guarda en Hive
              },
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}