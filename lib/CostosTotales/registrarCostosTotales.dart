import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class RegistrarCostosTotalesPage extends StatefulWidget {
  final VoidCallback onGuardado;

  const RegistrarCostosTotalesPage({super.key, required this.onGuardado});

  @override
  State<RegistrarCostosTotalesPage> createState() =>
      _RegistrarCostosTotalesPageState();
}

class _RegistrarCostosTotalesPageState
    extends State<RegistrarCostosTotalesPage> {
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> _obras = [];
  int? _obraSeleccionadaId; // <-- Cambia aquí

  final _presupuestoController = TextEditingController();
  final _montoManoObraController = TextEditingController();
  final _montoHerramientasController = TextEditingController();
  final _montoOtrasController = TextEditingController();

  double _montoMateriales = 0.0;

  @override
  void initState() {
    super.initState();
    _cargarObras();
  }

  Future<void> _cargarObras() async {
    final db = await DatabaseHelper.instance.database;
    final obras = await db.query('registroobras');
    setState(() => _obras = obras);
  }

  Future<void> _actualizarMontoMateriales(int obraId) async {
    final db = await DatabaseHelper.instance.database;
    final res = await db.rawQuery(
      'SELECT SUM(cantidad * costoUnitario) as total FROM materialesusados WHERE idObra = ?',
      [obraId],
    );
    setState(() {
      _montoMateriales = (res.first['total'] ?? 0.0) as double;
    });
  }

  void _onObraSeleccionada(int? id) {
    setState(() {
      _obraSeleccionadaId = id;
    });
    if (id != null) {
      _actualizarMontoMateriales(id);
    } else {
      setState(() => _montoMateriales = 0.0);
    }
  }

  Future<void> _guardarCostosTotales() async {
    if (!_formKey.currentState!.validate()) return;
    if (_obraSeleccionadaId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecciona una obra')));
      return;
    }

    final presupuesto = double.tryParse(_presupuestoController.text) ?? 0.0;
    final montoManoObra = double.tryParse(_montoManoObraController.text) ?? 0.0;
    final montoHerramientas =
        double.tryParse(_montoHerramientasController.text) ?? 0.0;
    final montoOtras = double.tryParse(_montoOtrasController.text) ?? 0.0;

    final totalGastado =
        _montoMateriales + montoManoObra + montoHerramientas + montoOtras;
    if (totalGastado > presupuesto) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'La suma de todos los montos no puede superar el presupuesto (\$${presupuesto.toStringAsFixed(2)})',
          ),
        ),
      );
      return;
    }

    final db = await DatabaseHelper.instance.database;
    await db.insert('costostotales', {
      'idObra': _obraSeleccionadaId,
      'presupuesto': presupuesto,
      'montoMateriales': _montoMateriales,
      'montoManoObra': montoManoObra,
      'montoHerramientas': montoHerramientas,
      'montoOtras': montoOtras,
      'fechaRegistro': DateTime.now().toIso8601String(),
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Costos totales guardados')));
    widget.onGuardado();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Costos Totales'),
        backgroundColor: const Color(0xFFFFFBE6),
        foregroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFFFFFBE6),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<int>(
                hint: const Text('Selecciona una Obra'),
                value: _obraSeleccionadaId,
                onChanged: _onObraSeleccionada,
                items: _obras.map((obra) {
                  return DropdownMenuItem<int>(
                    value: obra['id'] as int,
                    child: Text('${obra['nombre']} - ${obra['cliente']}'),
                  );
                }).toList(),
                validator: (value) =>
                    value == null ? 'Selecciona una obra' : null,
              ),
              TextFormField(
                controller: _presupuestoController,
                decoration: const InputDecoration(
                  labelText: 'Presupuesto total (\$)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 14),
              ListTile(
                tileColor: Colors.orange.shade50,
                title: const Text(
                  'Monto total de materiales:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Text('\$${_montoMateriales.toStringAsFixed(2)}'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _montoManoObraController,
                decoration: const InputDecoration(
                  labelText: 'Monto de Mano de Obra (\$)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _montoHerramientasController,
                decoration: const InputDecoration(
                  labelText: 'Monto de Herramientas (\$)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _montoOtrasController,
                decoration: const InputDecoration(
                  labelText: 'Monto de Otras Cosas (\$)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarCostosTotales,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Guardar Costos Totales',
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
