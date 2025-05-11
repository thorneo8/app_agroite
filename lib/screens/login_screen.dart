import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'company_dashboard_screen.dart';
import 'create_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || !value.contains('@')) {
                    return 'Ingrese un email válido';
                  }
                  return null;
                },
                onSaved: (value) => email = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese su contraseña';
                  }
                  return null;
                },
                onSaved: (value) => password = value!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    final empresasBox = Hive.box('empresas');
                    final tecnicosBox = Hive.box('tecnicos');

                    // Buscar si es empresa
                    final empresa = empresasBox.values.firstWhere(
                      (e) => e['email'] == email && e['password'] == password,
                      orElse: () => null,
                    );

                    if (empresa != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CompanyDashboardScreen(),
                        ),
                      );
                      return;
                    }

                    // Buscar si es técnico
                    final tecnico = tecnicosBox.values.firstWhere(
                      (t) => t['email'] == email,
                      orElse: () => null,
                    );

                    if (tecnico != null) {
                      if (tecnico['activo'] != true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Usuario desactivado. Contacte con su empresa.')),
                        );
                        return;
                      }

                      if (tecnico['password'] == null) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreatePasswordScreen(tecnicoId: tecnico['id']),
                          ),
                        );
                        return;
                      }

                      if (tecnico['password'] == password) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Login técnico exitoso (falta redirigir a panel)')),
                        );
                        return;
                      }
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Credenciales incorrectas')),
                    );
                  }
                },
                child: const Text('Entrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}