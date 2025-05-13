// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../services/database_service.dart';

class RegisterCompanyScreen extends StatefulWidget {
  const RegisterCompanyScreen({super.key});

  @override
  State<RegisterCompanyScreen> createState() => RegisterCompanyScreenState();
}

class RegisterCompanyScreenState extends State<RegisterCompanyScreen> {
  final _formKey = GlobalKey<FormState>();
  String companyName = '';
  String email = '';
  String password = '';
  String phone = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Empresa')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nombre de la Empresa'),
                validator: (v) => (v == null || v.isEmpty) ? 'Por favor ingrese el nombre' : null,
                onSaved: (v) => companyName = v!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => (v == null || v.isEmpty) ? 'Por favor ingrese el email' : null,
                onSaved: (v) => email = v!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Teléfono'),
                validator: (v) => (v == null || v.isEmpty) ? 'Por favor ingrese el teléfono' : null,
                onSaved: (v) => phone = v!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (v) => (v == null || v.isEmpty) ? 'Por favor ingrese la contraseña' : null,
                onSaved: (v) => password = v!,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  _formKey.currentState!.save();

                  await DatabaseService().registerEmpresa(
                    nombre: companyName,
                    email: email,
                    telefono: phone,
                    password: password,
                  );

                  final empresas = await DatabaseService().getEmpresas();
                  // ignore: avoid_print
                  print('📋 Empresas en BD tras inserción: $empresas');

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Empresa registrada en local')),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}