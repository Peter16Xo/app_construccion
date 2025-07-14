import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class MyHomePageVentanaRegistro extends StatefulWidget {
  final String title;
  const MyHomePageVentanaRegistro({super.key, required this.title});

  @override
  State<MyHomePageVentanaRegistro> createState() => _MyHomePageVentanaRegistroState();
}

class _MyHomePageVentanaRegistroState extends State<MyHomePageVentanaRegistro> {
  List<Map<String, dynamic>> _usuarios = [];

  @override
  void initState() {
    super.initState();
    _leerUsuariosJson();
  }

  Future<void> _leerUsuariosJson() async {
    final String data = await rootBundle.loadString('assets/usuarios.json');
    final List<dynamic> jsonResult = json.decode(data);
    setState(() {
      _usuarios = jsonResult.cast<Map<String, dynamic>>();
    });
  }
  final _formKey = GlobalKey<FormState>();
  final _cedulaController = TextEditingController();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _direccionController = TextEditingController();
  bool _aceptaTerminos = false;
  bool _recibirNotificaciones = false;

  Future<void> _guardarRegistro() async {
    if (_formKey.currentState!.validate()) {
      if (!_aceptaTerminos) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debe aceptar los términos y condiciones')),
        );
        return;
      }

      // Nuevo usuario
      final nuevoUsuario = {
        'cedula': _cedulaController.text,
        'nombres': _nombresController.text,
        'apellidos': _apellidosController.text,
        'direccion': _direccionController.text,
        'aceptaTerminos': _aceptaTerminos,
        'recibirNotificaciones': _recibirNotificaciones,
      };

      // Actualiza la lista local y el JSON (solo en memoria, no se guarda en archivo en Flutter estándar)
      setState(() {
        _usuarios.add(nuevoUsuario);
      });

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
    }
  }

  void _mostrarUsuariosDialogo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usuarios registrados (JSON)'),
        content: SizedBox(
          width: double.maxFinite,
          child: _usuarios.isEmpty
              ? const Text('No hay usuarios registrados')
              : ListView(
                  shrinkWrap: true,
                  children: _usuarios.map((u) => ListTile(
                    title: Text('${u['nombres']} ${u['apellidos']}'),
                    subtitle: Text('Cédula: ${u['cedula']}\nDirección: ${u['direccion']}'),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(u['aceptaTerminos'] ? 'Aceptó términos' : 'No aceptó'),
                        Text(u['recibirNotificaciones'] ? 'Recibe notificaciones' : 'No recibe'),
                      ],
                    ),
                  )).toList(),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
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
        child: ListView(
          children: [
            ElevatedButton(
              onPressed: _mostrarUsuariosDialogo,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Ver registros JSON'),
            ),
            const SizedBox(height: 10),
            Form(
              key: _formKey,
              child: Column(
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
          ],
        ),
      ),
    );
  }
}
