import 'package:flutter/material.dart';
import '../services/database_service.dart';

class RegisterCompanyScreen extends StatefulWidget {
  const RegisterCompanyScreen({super.key});

  @override
  _RegisterCompanyScreenState createState() => _RegisterCompanyScreenState();
}

class _RegisterCompanyScreenState extends State<RegisterCompanyScreen> {
  final _formKey = GlobalKey<FormState>();
  String companyName = '';
  String email = '';
  String password = '';
  String phone = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registrar Empresa')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nombre de la Empresa'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el nombre';
                  }
                  return null;
                },
                onSaved: (value) => companyName = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || !value.contains('@')) {
                    return 'Ingrese un email válido';
                  }
                  return null;
                },
                onSaved: (value) => email = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Teléfono'),
                onSaved: (value) => phone = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Mínimo 6 caracteres';
                  }
                  return null;
                },
                onSaved: (value) => password = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    Map<String, dynamic> empresa = {
                      'nombre': companyName,
                      'email': email,
                      'telefono': phone,
                      'password': password,
                    };

                    await DatabaseService().insertEmpresa(empresa);
                    
                    // ✅ AÑADIR ESTO para verificar en consola:
                    List<Map<String, dynamic>> empresas = await DatabaseService().getEmpresas();
                    print('Empresas en la base de datos:');
                    empresas.forEach((e) => print(e));

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Empresa registrada en local')),
                    );

                    Navigator.pop(context); // Navegar a la pantalla anterior
                  }
                },
                child: Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}