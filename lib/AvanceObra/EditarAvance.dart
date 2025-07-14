import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_construccion/database/database_helper.dart';
import 'package:app_construccion/AvanceObra/avanceobra.dart'; // Importa la clase Avance desde avanceobra.dart

// Asegúrate de que tu clase Obra esté disponible.
// Si está en models.dart, impórtala:
// import 'package:app_construccion/models/models.dart';
// Si la tienes definida en database_helper.dart o en registraravance.dart,
// asegúrate de que sea accesible o cópiala aquí si es necesario.
class Obra {
  // Copia de la clase Obra si no está globalmente accesible
  final int id;
  final String nombre;

  Obra({required this.id, required this.nombre});

  factory Obra.fromMap(Map<String, dynamic> map) {
    return Obra(id: map['id'], nombre: map['nombre']);
  }
}

class EditarAvancePage extends StatefulWidget {
  final Avance avance; // El avance que se va a editar

  const EditarAvancePage({super.key, required this.avance});

  @override
  State<EditarAvancePage> createState() => _EditarAvancePageState();
}

class _EditarAvancePageState extends State<EditarAvancePage> {
  final _fechaController = TextEditingController();
  final _porcentajeController = TextEditingController();
  final _comentarioController = TextEditingController();

  String? _selectedObraName;
  List<Obra> _obras = [];

  bool _aprobada = false;
  bool _noAprobada = false;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _loadObras(); // Cargar las obras para el dropdown

    // Precargar los datos del avance que se está editando
    _fechaController.text = widget.avance.fechaAvance;
    _porcentajeController.text = widget.avance.porcentaje.toString();
    _comentarioController.text = widget
        .avance
        .comentario; // No es necesario '?? '' ' si es String NOT NULL

    // Establecer el estado de los checkboxes de inspección de calidad
    if (widget.avance.inspeccionCalidad == 'Aprobada') {
      _aprobada = true;
    } else if (widget.avance.inspeccionCalidad == 'No aprobada') {
      _noAprobada = true;
    }
    // _selectedObraName se establecerá después de que _loadObras() cargue las obras.
  }

  @override
  void dispose() {
    _fechaController.dispose();
    _porcentajeController.dispose();
    _comentarioController.dispose();
    super.dispose();
  }

  Future<void> _loadObras() async {
    try {
      final List<Map<String, dynamic>> obraMaps = await _dbHelper
          .queryAllObras();
      if (!mounted) return;

      setState(() {
        _obras = obraMaps.map((map) => Obra.fromMap(map)).toList();
        // Intentar seleccionar la obra del avance actual
        if (_obras.isNotEmpty) {
          _selectedObraName = widget.avance.nombreObra;
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar obras: $e')));
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && mounted) {
      setState(() {
        _fechaController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _actualizarAvance() async {
    // Validaciones básicas
    if (_selectedObraName == null || _selectedObraName!.isEmpty) {
      _showSnackBar('Por favor, selecciona una obra.', Colors.red);
      return;
    }
    if (_fechaController.text.isEmpty ||
        _porcentajeController.text.isEmpty ||
        _comentarioController.text.isEmpty) {
      _showSnackBar('Por favor, completa todos los campos.', Colors.red);
      return;
    }
    if (!_aprobada && !_noAprobada) {
      _showSnackBar(
        'Selecciona la inspección de calidad (Aprobada/No aprobada).',
        Colors.red,
      );
      return;
    }

    try {
      final Obra? selectedObra = _obras.firstWhere(
        (obra) => obra.nombre == _selectedObraName,
        orElse: () => throw Exception('Obra seleccionada no encontrada.'),
      );

      if (selectedObra == null) {
        _showSnackBar('Error: Obra seleccionada no válida.', Colors.red);
        return;
      }

      final double porcentajeAvance = double.parse(_porcentajeController.text);
      String inspeccionCalidad = '';
      if (_aprobada && _noAprobada) {
        inspeccionCalidad = 'Aprobada y No aprobada';
      } else if (_aprobada) {
        inspeccionCalidad = 'Aprobada';
      } else if (_noAprobada) {
        inspeccionCalidad = 'No aprobada';
      }

      // Crear un mapa con los datos actualizados del avance
      final Map<String, dynamic> avanceActualizadoMap = {
        'id': widget.avance.id, // ¡CRUCIAL! El ID del avance existente
        'obraId': selectedObra.id,
        'nombreObra': selectedObra.nombre,
        'fecha': _fechaController.text,
        'porcentaje': porcentajeAvance,
        'comentario': _comentarioController.text,
        'inspeccionCalidad': inspeccionCalidad,
      };

      await _dbHelper.updateAvance(
        avanceActualizadoMap,
      ); // Llamar al nuevo método de actualización

      if (!mounted) return;
      _showSnackBar('Avance actualizado con éxito.', Colors.green);

      // Regresar a la pantalla anterior (AvanceObraPage)
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Error al actualizar avance: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Avance de Obra'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selecciona la Obra:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedObraName,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Obra',
              ),
              items: _obras.map((obra) {
                return DropdownMenuItem<String>(
                  value: obra.nombre,
                  child: Text(obra.nombre),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedObraName = newValue;
                });
              },
              isExpanded: true,
              hint: _obras.isEmpty
                  ? const Text('Cargando obras...')
                  : const Text('Selecciona una obra'),
            ),
            const SizedBox(height: 16),

            Text(
              'Fecha del Avance:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _fechaController,
              readOnly: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Fecha (DD/MM/AAAA)',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 16),

            Text(
              'Porcentaje de Avance:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _porcentajeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Ej: 75.50',
                suffixText: '%',
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Comentario/Observaciones:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _comentarioController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Detalles del avance...',
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Inspección de Calidad:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Row(
              children: [
                Checkbox(
                  value: _aprobada,
                  onChanged: (bool? value) {
                    setState(() {
                      _aprobada = value!;
                      if (value) _noAprobada = false;
                    });
                  },
                ),
                const Text('Aprobada'),
                const SizedBox(width: 20),
                Checkbox(
                  value: _noAprobada,
                  onChanged: (bool? value) {
                    setState(() {
                      _noAprobada = value!;
                      if (value) _aprobada = false;
                    });
                  },
                ),
                const Text('No Aprobada'),
              ],
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _actualizarAvance, // Llama a la función de actualización
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Guardar Cambios',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}