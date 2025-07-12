import 'package:app_construccion/PersonalAsignado/listarpersonal.dart';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class RegistrarPersonalPage extends StatefulWidget {
  const RegistrarPersonalPage({super.key});

  @override
  State<RegistrarPersonalPage> createState() => _RegistrarObraPageState();
}

class _RegistrarObraPageState extends State<RegistrarPersonalPage> {
  final _formKey = GlobalKey<FormState>();
  final _cedulaController = TextEditingController();
  final _nombreCompletoController = TextEditingController();
  final _cargoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _tareaController = TextEditingController();
  bool asistencia = false;

  // Metodos para almacenar, refrescar y cargar las obras
  List<String> _obras = [];
  String? _obraSeleccionada;

  @override
  void initState() {
    super.initState();
    _cargarObras();
  }

  Future<void> _cargarObras() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('registroobras');
    setState(() {
      _obras = result.map((row) => row['nombre'].toString()).toList();
    });
  }

  // Metodo para guardar los registros
  Future<void> _guardarPersonal() async {
    if (_formKey.currentState!.validate()) {
      final db = await DatabaseHelper.instance.database;

      await db.insert('personalasignado', {
        'nombreObra': _obraSeleccionada!,
        'cedula': _cedulaController.text.trim(),
        'nombreCompleto': _nombreCompletoController.text.trim(),
        'cargo': _cargoController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'tarea': _tareaController.text.trim(),
        'asistencia': asistencia ? 1 : 0,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Obra registrada correctamente')),
      );
      limpiarCampos();
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
    }
  }

  // Metodo para limpiar los campos
  void limpiarCampos() {
    _obraSeleccionada = null;
    _cedulaController.clear();
    _nombreCompletoController.clear();
    _cargoController.clear();
    _telefonoController.clear();
    _tareaController.clear();
    asistencia = false;
  }

  void _verpersonalR() {
    // sirve para direccionar desde una ventana hacia otra
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListaPersonalPage(), // Lista con base de datos
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBE6),
      appBar: AppBar(
        title: const Text('Registrar Personal'),
        backgroundColor: const Color(0xFFFFFBE6),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _obraSeleccionada,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la Obra',
                ),
                items: _obras.map((obra) {
                  return DropdownMenuItem<String>(
                    value: obra,
                    child: Text(obra),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _obraSeleccionada = value;
                  });
                },
                validator: (value) => value == null ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _cedulaController,
                decoration: const InputDecoration(labelText: 'Cedula'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _nombreCompletoController,
                decoration: const InputDecoration(labelText: 'Nombre Completo'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _cargoController,
                decoration: const InputDecoration(labelText: 'Cargo'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(labelText: 'Telefono'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _tareaController,
                decoration: const InputDecoration(labelText: 'Tarea'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              CheckboxListTile(
                title: Text("Asistencia"),
                value: asistencia,
                onChanged: (bool? value) {
                  setState(() {
                    asistencia = value!;
                  });
                },
              ),
              const SizedBox(height: 15),

              // Boton para guardar el personal
              ElevatedButton(
                onPressed: _guardarPersonal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Guardar Registro',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              // Boton para ver los registros
              const SizedBox(height: 15),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _verpersonalR,
                child: const Text(
                  'Ver Personas Registradas',
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