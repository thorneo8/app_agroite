// lib/screens/register_company_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_riego/services/api_service.dart';
import 'package:app_riego/models/empresa.dart';

class RegisterCompanyScreen extends StatefulWidget {
  const RegisterCompanyScreen({super.key});

  @override
  State<RegisterCompanyScreen> createState() => _RegisterCompanyScreenState();
}

class _RegisterCompanyScreenState extends State<RegisterCompanyScreen> {
  final _formKey = GlobalKey<FormState>();
  String nombre   = '';
  String email    = '';
  String telefon  = ''; // opcional, no se envía al endpoint
  String password = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Empresa')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Nombre
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nombre de la Empresa'),
                validator: (v) => (v == null || v.isEmpty) ? 'Obligatorio' : null,
                onSaved: (v) => nombre = v!.trim(),
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || v.isEmpty) ? 'Obligatorio' : null,
                onSaved: (v) => email = v!.trim(),
              ),
              const SizedBox(height: 16),

              // Teléfono (opcional)
              TextFormField(
                decoration: const InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
                onSaved: (v) => telefon = v!.trim(),
              ),
              const SizedBox(height: 16),

              // Contraseña
              TextFormField(
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (v) => (v == null || v.isEmpty) ? 'Obligatorio' : null,
                onSaved: (v) => password = v!.trim(),
              ),
              const SizedBox(height: 32),

              _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Registrar'),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      final Empresa nueva = await Provider.of<ApiService>(context, listen: false)
        .createEmpresa(
          nombre: nombre,
          email: email,
          password: password,
        );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Empresa registrada correctamente')),
      );
      Navigator.pop(context, nueva);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
