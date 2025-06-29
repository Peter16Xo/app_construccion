import 'package:flutter/material.dart';
import 'listaobras.dart';

class RegistrarObraPage extends StatefulWidget {
  const RegistrarObraPage({super.key});

  @override
  State<RegistrarObraPage> createState() => _RegistrarObraPageState();
}

class _RegistrarObraPageState extends State<RegistrarObraPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _clienteController = TextEditingController();
  final _ubicacionController = TextEditingController();
  DateTime? _fechaInicio;
  DateTime? _fechaFin;

  static int contadorObras = 0;
  static List<Map<String, dynamic>> obras = [];

  Future<void> _selectFechaInicio() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _fechaInicio = picked;
      });
    }
  }

  Future<void> _selectFechaFin() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaInicio ?? DateTime.now(),
      firstDate: _fechaInicio ?? DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _fechaFin = picked;
      });
    }
  }

  void _guardarObra() {
  if (_formKey.currentState!.validate() && _fechaInicio != null && _fechaFin != null) {
    setState(() {
      contadorObras++;
      obras.add({
        'numero': contadorObras,
        'nombre': _nombreController.text,
        'cliente': _clienteController.text,
        'ubicacion': _ubicacionController.text,
        'fechaInicio': _fechaInicio,
        'fechaFin': _fechaFin,
      });

      // Limpiar campos después de guardar
      _nombreController.clear();
      _clienteController.clear();
      _ubicacionController.clear();
      _fechaInicio = null;
      _fechaFin = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Obra registrada correctamente')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Completa todos los campos')),
    );
  }
}


  void _verObras() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ListaObrasPage(obras: obras)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBE6),
      appBar: AppBar(
        title: const Text('Registrar Obra'),
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
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre del Proyecto'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _clienteController,
                decoration: const InputDecoration(labelText: 'Cliente'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _ubicacionController,
                decoration: const InputDecoration(labelText: 'Ubicación'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 15),
              ListTile(
                title: Text(_fechaInicio == null
                    ? 'Seleccionar Fecha de Inicio'
                    : 'Inicio: ${_fechaInicio!.day}/${_fechaInicio!.month}/${_fechaInicio!.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectFechaInicio,
              ),
              ListTile(
                title: Text(_fechaFin == null
                    ? 'Seleccionar Fecha Fin Estimada'
                    : 'Fin: ${_fechaFin!.day}/${_fechaFin!.month}/${_fechaFin!.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectFechaFin,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarObra,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Guardar Obra', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 15),
              OutlinedButton(
  style: OutlinedButton.styleFrom(
    foregroundColor: Theme.of(context).colorScheme.primary,
    side: BorderSide(color: Theme.of(context).colorScheme.primary),
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  onPressed: _verObras,
  child: const Text('Ver Obras Registradas', style: TextStyle(fontWeight: FontWeight.bold)),
),

            ],
          ),
        ),
      ),
    );
  }
}
