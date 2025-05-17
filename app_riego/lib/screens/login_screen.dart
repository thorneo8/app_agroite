// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_riego/services/api_service.dart';
import 'package:app_riego/models/empresa.dart';
import 'package:app_riego/screens/company_dashboard_screen.dart';
import 'package:app_riego/screens/technician_dashboard_screen.dart';
import 'package:app_riego/screens/client_dashboard_screen.dart';
import 'package:app_riego/screens/create_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    (v == null || !v.contains('@')) ? 'Email inválido' : null,
                onSaved: (v) => _email = v!.trim(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Ingrese contraseña' : null,
                onSaved: (v) => _password = v!.trim(),
              ),
              const SizedBox(height: 24),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Entrar'),
                    ),
              // Agrega aquí el botón para crear contraseña
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreatePasswordScreen(),
                    ),
                  );
                },
                child: const Text('¿Primera vez? Crea tu contraseña'),
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
      final api = Provider.of<ApiService>(context, listen: false);
      final user = await api.loginGeneral(
        email: _email,
        password: _password,
      );

      if (!mounted) return;
      final role = user['role'] as String;

      switch (role) {
        case 'empresa':
          // Convertimos el JSON a Empresa y pasamos al dashboard
          final empresa = Empresa.fromJson(user);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CompanyDashboardScreen(empresa: empresa),
            ),
          );
          break;

        case 'tecnico':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const TechnicianDashboardScreen(),
            ),
          );
          break;

        case 'cliente':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ClientDashboardScreen(clientData: user),
            ),
          );
          break;

        default:
          throw Exception('Rol desconocido: $role');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de login: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
