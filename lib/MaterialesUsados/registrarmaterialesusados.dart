import 'package:flutter/material.dart';
import 'listamateriales.dart';

class RegistrarMaterialesUsadosPage extends StatefulWidget {
  final List<Map<String, dynamic>> obras;

  const RegistrarMaterialesUsadosPage({super.key, required this.obras});

  @override
  State<RegistrarMaterialesUsadosPage> createState() =>
      _RegistrarMaterialesPageState();
}

class _RegistrarMaterialesPageState
    extends State<RegistrarMaterialesUsadosPage> {
  final _formKey = GlobalKey<FormState>();
  final _materialController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _costoController = TextEditingController();
  final _observacionesController = TextEditingController();
  DateTime? _fechaUso;
  Map<String, dynamic>? _obraSeleccionada;
  static int contadorMateriales = 0;

  static List<Map<String, dynamic>> materiales = [];

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _fechaUso = picked);
  }

  void _guardarMaterial() {
    if (_formKey.currentState!.validate() &&
        _fechaUso != null &&
        _obraSeleccionada != null) {
      setState(() {
        contadorMateriales++;

        materiales.add({
          'obra': _obraSeleccionada,
          'numero': contadorMateriales,
          'material': _materialController.text,
          'cantidad': _cantidadController.text,
          'costo': _costoController.text,
          'fechaUso': _fechaUso,
          'observaciones': _observacionesController.text,
        });

        // Limpiar campos
        _materialController.clear();
        _cantidadController.clear();
        _costoController.clear();
        _observacionesController.clear();
        _fechaUso = null;
        _obraSeleccionada = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Material registrado correctamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
    }
  }

  void _verMateriales() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ListaMaterialesPage(materiales: materiales),
      ),
    );
  }

  String _formatFecha(DateTime? fecha) {
    if (fecha == null) return 'Seleccionar Fecha de Uso';
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBE6),
      appBar: AppBar(
        title: const Text('Registrar Material Usado'),
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
              DropdownButtonFormField<Map<String, dynamic>>(
                hint: const Text('Selecciona una Obra'),
                value: _obraSeleccionada,
                onChanged: (obra) => setState(() => _obraSeleccionada = obra),
                items: widget.obras.map((obra) {
                  final nombreCliente =
                      '${obra['nombre']} - ${obra['cliente']}';
                  return DropdownMenuItem(
                    value: obra,
                    child: Text(nombreCliente),
                  );
                }).toList(),
                validator: (value) =>
                    value == null ? 'Selecciona una obra' : null,
              ),
              TextFormField(
                controller: _materialController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Material',
                ),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _cantidadController,
                decoration: const InputDecoration(labelText: 'Cantidad'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _costoController,
                decoration: const InputDecoration(
                  labelText: 'Costo por unidad (\$)',
                ),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              ListTile(
                title: Text(_formatFecha(_fechaUso)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _seleccionarFecha,
              ),
              TextFormField(
                controller: _observacionesController,
                decoration: const InputDecoration(labelText: 'Observaciones'),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarMaterial,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Guardar Material',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
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
                onPressed: _verMateriales,
                child: const Text(
                  'Ver Materiales Registrados',
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
