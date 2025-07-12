import 'package:flutter/material.dart';

class EditarMaterialPage extends StatefulWidget {
  final Map<String, dynamic> material;
  final Function(Map<String, dynamic>) onActualizar;

  const EditarMaterialPage({
    super.key,
    required this.material,
    required this.onActualizar,
  });

  @override
  State<EditarMaterialPage> createState() => _EditarMaterialPageState();
}

class _EditarMaterialPageState extends State<EditarMaterialPage> {
  late TextEditingController _nombreController;
  late TextEditingController _cantidadController;
  late TextEditingController _costoController;
  late TextEditingController _observacionesController;
  DateTime? _fechaUso;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.material['nombre']);
    _cantidadController = TextEditingController(
      text: widget.material['cantidad'].toString(),
    );
    _costoController = TextEditingController(
      text: widget.material['costoUnitario'].toString(),
    );
    _observacionesController = TextEditingController(
      text: widget.material['observaciones'] ?? '',
    );
    _fechaUso = DateTime.tryParse(widget.material['fechaUso']);
  }

  Future<void> _selectFechaUso() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaUso ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _fechaUso = picked);
  }

  void _guardarCambios() {
    final actualizado = {
      ...widget.material,
      'nombre': _nombreController.text,
      'cantidad': int.tryParse(_cantidadController.text) ?? 0,
      'costoUnitario': double.tryParse(_costoController.text) ?? 0.0,
      'fechaUso': _fechaUso?.toIso8601String() ?? '',
      'observaciones': _observacionesController.text,
    };

    widget.onActualizar(actualizado);
    Navigator.pop(context);
  }

  String _formatFecha(DateTime? fecha) {
    if (fecha == null) return 'Seleccionar Fecha de Uso';
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Material Usado'),
        backgroundColor: const Color(0xFFFFFBE6),
        foregroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFFFFFBE6),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Material',
              ),
            ),
            TextField(
              controller: _cantidadController,
              decoration: const InputDecoration(labelText: 'Cantidad'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _costoController,
              decoration: const InputDecoration(
                labelText: 'Costo por unidad (\$)',
              ),
              keyboardType: TextInputType.number,
            ),
            ListTile(
              title: Text(_formatFecha(_fechaUso)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectFechaUso,
            ),
            TextField(
              controller: _observacionesController,
              decoration: const InputDecoration(labelText: 'Observaciones'),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _guardarCambios,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
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
    );
  }
}
