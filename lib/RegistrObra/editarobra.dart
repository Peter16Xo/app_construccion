import 'package:flutter/material.dart';

class EditarObraPage extends StatefulWidget {
  final Map<String, dynamic> obra;
  final void Function(Map<String, dynamic>) onActualizar;

  const EditarObraPage({
    super.key,
    required this.obra,
    required this.onActualizar,
  });

  @override
  State<EditarObraPage> createState() => _EditarObraPageState();
}

class _EditarObraPageState extends State<EditarObraPage> {
  late TextEditingController _nombreController;
  late TextEditingController _clienteController;
  late TextEditingController _ubicacionController;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.obra['nombre']);
    _clienteController = TextEditingController(text: widget.obra['cliente']);
    _ubicacionController = TextEditingController(text: widget.obra['ubicacion']);
    _fechaInicio = widget.obra['fechaInicio'];
    _fechaFin = widget.obra['fechaFin'];
  }

  Future<void> _selectFechaInicio() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaInicio ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _fechaInicio = picked);
  }

  Future<void> _selectFechaFin() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaFin ?? DateTime.now(),
      firstDate: _fechaInicio ?? DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _fechaFin = picked);
  }

  void _guardarCambios() {
    final obraActualizada = {
      ...widget.obra,
      'nombre': _nombreController.text,
      'cliente': _clienteController.text,
      'ubicacion': _ubicacionController.text,
      'fechaInicio': _fechaInicio,
      'fechaFin': _fechaFin,
    };
    widget.onActualizar(obraActualizada);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Obra'),
        backgroundColor: const Color(0xFFFFFBE6),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFFFFBE6),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre del Proyecto'),
            ),
            TextField(
              controller: _clienteController,
              decoration: const InputDecoration(labelText: 'Cliente'),
            ),
            TextField(
              controller: _ubicacionController,
              decoration: const InputDecoration(labelText: 'Ubicación'),
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
              onPressed: _guardarCambios,
              child: const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
