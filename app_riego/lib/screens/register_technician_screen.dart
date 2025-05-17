// lib/screens/register_technician_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_riego/services/api_service.dart';

class RegisterTechnicianScreen extends StatefulWidget {
  final int empresaId;
  const RegisterTechnicianScreen({
    super.key,
    required this.empresaId,
  });

  @override
  State<RegisterTechnicianScreen> createState() =>
      _RegisterTechnicianScreenState();
}

class _RegisterTechnicianScreenState
    extends State<RegisterTechnicianScreen> {
  final _formKey = GlobalKey<FormState>();
  String _nombre   = '';
  String _email    = '';
  String _telefono = '';
  bool _loading    = false;

  @override
  Widget build(BuildContext context) {
    // ¡Aquí empieza la Material context! 
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Técnico')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Nombre y Apellidos'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Obligatorio' : null,
                onSaved: (v) => _nombre = v!.trim(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) =>
                    (v == null || !v.contains('@')) ? 'Email inválido' : null,
                onSaved: (v) => _email = v!.trim(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Teléfono'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Obligatorio' : null,
                onSaved: (v) => _telefono = v!.trim(),
              ),
              const SizedBox(height: 32),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Registrar Técnico'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _loading = true);

    try {
      final nuevoId = await Provider.of<ApiService>(
        context,
        listen: false,
      ).createTecnico(
        empresaId: widget.empresaId,
        nombreApellido: _nombre,
        email: _email,
        telefono: _telefono,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Técnico creado (ID: $nuevoId)')),
      );
      Navigator.pop(context, nuevoId.toString());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
