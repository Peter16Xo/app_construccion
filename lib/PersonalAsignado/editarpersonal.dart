import 'package:flutter/material.dart';

class EditarPersonalPage extends StatefulWidget {
  final Map<String, dynamic> personal;
  final List<String> obrasDisponibles;
  final void Function(Map<String, dynamic>) onActualizar;

  const EditarPersonalPage({
    super.key,
    required this.personal,
    required this.obrasDisponibles,
    required this.onActualizar,
  });

  @override
  State<EditarPersonalPage> createState() => EditarPersonalPageState();
}

class EditarPersonalPageState extends State<EditarPersonalPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _cedulaController;
  late TextEditingController _nombreCompletoController;
  late TextEditingController _cargoController;
  late TextEditingController _telefonoController;
  late TextEditingController _tareaController;

  String? _obraSeleccionada;
  bool asistencia = false;

  @override
  void initState() {
    super.initState();
    _obraSeleccionada = widget.personal['nombreObra'];
    _cedulaController = TextEditingController(text: widget.personal['cedula']);
    _nombreCompletoController = TextEditingController(
      text: widget.personal['nombreCompleto'],
    );
    _cargoController = TextEditingController(text: widget.personal['cargo']);
    _telefonoController = TextEditingController(
      text: widget.personal['telefono'],
    );
    _tareaController = TextEditingController(text: widget.personal['tarea']);
    asistencia = widget.personal['asistencia'] == 1;
  }

  // Metodo para guardar los registros
  void _guardarCambiosPersonal() {
    if (_formKey.currentState!.validate()) {
      final personaActualizada = {
        'id': widget.personal['id'],
        'nombreObra': _obraSeleccionada ?? '',
        'cedula': _cedulaController.text.trim(),
        'nombreCompleto': _nombreCompletoController.text.trim(),
        'cargo': _cargoController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'tarea': _tareaController.text.trim(),
        'asistencia': asistencia ? 1 : 0,
      };

      widget.onActualizar(personaActualizada);
      Navigator.pop(context);
    }
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
                items: widget.obrasDisponibles.map((obra) {
                  return DropdownMenuItem(value: obra, child: Text(obra));
                }).toList(),
                onChanged: (value) => setState(() => _obraSeleccionada = value),
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
                onPressed: _guardarCambiosPersonal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Guardar Cambios',
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