import 'package:flutter/material.dart';

class MyHomePageVentanaRegistro extends StatefulWidget {
  final String title;
  const MyHomePageVentanaRegistro({super.key, required this.title});

  @override
  State<MyHomePageVentanaRegistro> createState() => _MyHomePageVentanaRegistroState();
}

class _MyHomePageVentanaRegistroState extends State<MyHomePageVentanaRegistro> {
  final _formKey = GlobalKey<FormState>();
  final _cedulaController = TextEditingController();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _direccionController = TextEditingController();
  bool _aceptaTerminos = false;
  bool _recibirNotificaciones = false;

  void _guardarRegistro() {
    if (_formKey.currentState!.validate()) {
      if (!_aceptaTerminos) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debe aceptar los términos y condiciones')),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario registrado correctamente')),
      );

      // Mostrar por 1.5 segundos y luego volver al login
      Future.delayed(const Duration(milliseconds: 1500), () {
        Navigator.pop(context);
      });

      // Limpia los campos
      _cedulaController.clear();
      _nombresController.clear();
      _apellidosController.clear();
      _direccionController.clear();
      setState(() {
        _aceptaTerminos = false;
        _recibirNotificaciones = false;
      });

      // Simula registro (puedes guardar en base de datos aquí)
      print('Cédula: ${_cedulaController.text}');
      print('Nombres: ${_nombresController.text}');
      print('Apellidos: ${_apellidosController.text}');
      print('Dirección: ${_direccionController.text}');
      print('Notificaciones: $_recibirNotificaciones');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFFFFBE6),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _cedulaController,
                decoration: const InputDecoration(labelText: 'Cédula'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _nombresController,
                decoration: const InputDecoration(labelText: 'Nombres'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _apellidosController,
                decoration: const InputDecoration(labelText: 'Apellidos'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(labelText: 'Dirección'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 15),
              CheckboxListTile(
                title: const Text('Aceptar términos y condiciones'),
                value: _aceptaTerminos,
                onChanged: (value) {
                  setState(() {
                    _aceptaTerminos = value ?? false;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Recibir notificaciones'),
                value: _recibirNotificaciones,
                onChanged: (value) {
                  setState(() {
                    _recibirNotificaciones = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarRegistro,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D4037),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Guardar',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
