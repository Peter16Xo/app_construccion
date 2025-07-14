import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class EditarCostosTotalesPage extends StatefulWidget {
  final Map<String, dynamic> costo;
  final VoidCallback onActualizado;

  const EditarCostosTotalesPage({
    super.key,
    required this.costo,
    required this.onActualizado,
  });

  @override
  State<EditarCostosTotalesPage> createState() =>
      _EditarCostosTotalesPageState();
}

class _EditarCostosTotalesPageState extends State<EditarCostosTotalesPage> {
  final _formKey = GlobalKey<FormState>();

  final _presupuestoController = TextEditingController();
  final _montoManoObraController = TextEditingController();
  final _montoHerramientasController = TextEditingController();
  final _montoOtrasController = TextEditingController();

  double _montoMateriales = 0.0;
  String _nombreObra = '';

  @override
  void initState() {
    super.initState();
    _presupuestoController.text = widget.costo['presupuesto'].toString();
    _montoMateriales = widget.costo['montoMateriales'] ?? 0.0;
    _montoManoObraController.text = widget.costo['montoManoObra'].toString();
    _montoHerramientasController.text = widget.costo['montoHerramientas']
        .toString();
    _montoOtrasController.text = widget.costo['montoOtras'].toString();
    _cargarNombreObra(widget.costo['idObra']);
  }

  Future<void> _cargarNombreObra(int idObra) async {
    final db = await DatabaseHelper.instance.database;
    final obras = await db.query(
      'registroobras',
      where: 'id = ?',
      whereArgs: [idObra],
    );
    if (obras.isNotEmpty) {
      setState(() {
        _nombreObra = obras.first['nombre'] as String;
      });
    }
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;
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
    await db.update(
      'costostotales',
      {
        'presupuesto': presupuesto,
        'montoManoObra': montoManoObra,
        'montoHerramientas': montoHerramientas,
        'montoOtras': montoOtras,
      },
      where: 'id = ?',
      whereArgs: [widget.costo['id']],
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Costos actualizados')));
    widget.onActualizado();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Costos Totales'),
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
              ListTile(
                title: Text(
                  _nombreObra,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Obra'),
                tileColor: Colors.orange.shade50,
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
                  'Monto total de materiales',
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
                onPressed: _guardarCambios,
                style: ElevatedButton.styleFrom(
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