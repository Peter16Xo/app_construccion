import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Necesitas agregar 'intl: ^0.18.1' a tu pubspec.yaml
import 'package:app_construccion/database/database_helper.dart'; // Ajusta esta ruta si es necesario

class Obra {
  final int id;
  final String nombre; // Asumo que la columna de nombre de la obra es 'nombre'

  Obra({required this.id, required this.nombre});

  factory Obra.fromMap(Map<String, dynamic> map) {
    return Obra(id: map['id'], nombre: map['nombre']);
  }
}

class RegistrarAvancePage extends StatefulWidget {
  const RegistrarAvancePage({super.key});

  @override
  State<RegistrarAvancePage> createState() => _RegistrarAvancePageState();
}

class _RegistrarAvancePageState extends State<RegistrarAvancePage> {
  final _fechaController = TextEditingController();
  final _porcentajeController = TextEditingController();
  final _comentarioController = TextEditingController();

  String? _selectedObraName; // Nombre de la obra seleccionada en el Dropdown
  List<Obra> _obras = []; // Lista de objetos Obra para el Dropdown

  bool _aprobada = false;
  bool _noAprobada = false;

  final DatabaseHelper _dbHelper =
      DatabaseHelper.instance; // Instancia de tu DatabaseHelper

  @override
  void initState() {
    super.initState();
    _loadObras(); // Cargar las obras al iniciar la pantalla
  }

  @override
  void dispose() {
    _fechaController.dispose();
    _porcentajeController.dispose();
    _comentarioController.dispose();
    super.dispose();
  }

  // Cargar la lista de obras desde la base de datos para el Dropdown
  Future<void> _loadObras() async {
    try {
      final List<Map<String, dynamic>> obraMaps = await _dbHelper
          .queryAllObras(); // Asumo un método queryAllObras()
      if (!mounted) return; // Verificar si el widget sigue montado

      setState(() {
        _obras = obraMaps.map((map) => Obra.fromMap(map)).toList();
        // Si hay obras y no se ha seleccionado ninguna, selecciona la primera por defecto
        if (_obras.isNotEmpty && _selectedObraName == null) {
          _selectedObraName = _obras.first.nombre;
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar obras: $e')));
    }
  }

  // Función para mostrar el DatePicker y actualizar el campo de fecha
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && mounted) {
      // Verificar si el widget sigue montado
      setState(() {
        _fechaController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  // Función para guardar el nuevo avance de obra en la base de datos
  void _guardarAvance() async {
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
      // Obtener el ID de la obra seleccionada por su nombre
      // Asumo que tienes un método para obtener el ID de la obra por su nombre
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
        inspeccionCalidad =
            'Aprobada y No aprobada'; // Caso inusual, pero manejado
      } else if (_aprobada) {
        inspeccionCalidad = 'Aprobada';
      } else if (_noAprobada) {
        inspeccionCalidad = 'No aprobada';
      }

      // Crear un mapa con los datos del nuevo avance para insertar en la BD
      final Map<String, dynamic> nuevoAvanceMap = {
        'obraId': selectedObra.id, // ID de la obra
        'nombreObra': selectedObra
            .nombre, // Nombre de la obra (si lo guardas en la tabla de avances)
        'fecha': _fechaController.text,
        'porcentaje': porcentajeAvance,
        'comentario': _comentarioController.text,
        'inspeccionCalidad':
            inspeccionCalidad, // Esto no está en tu modelo 'Avance' actual, pero se puede añadir
      };

      await _dbHelper.insertAvance(
        nuevoAvanceMap,
      ); // Asumo un método insertAvance() en DatabaseHelper

      if (!mounted) return; // Verificar si el widget sigue montado
      _showSnackBar('Avance registrado con éxito.', Colors.green);

      // Limpiar los campos después de guardar
      _fechaController.clear();
      _porcentajeController.clear();
      _comentarioController.clear();
      setState(() {
        _aprobada = false;
        _noAprobada = false;
        _selectedObraName = _obras.isNotEmpty
            ? _obras.first.nombre
            : null; // Resetear al primer elemento o nulo
      });
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Error al registrar avance: $e', Colors.red);
    }
  }

  // Función auxiliar para mostrar un SnackBar
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
        title: const Text('Registrar Avance de Obra'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown para seleccionar la Obra
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

            // Campo de Fecha
            Text(
              'Fecha del Avance:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _fechaController,
              readOnly:
                  true, // Para que el usuario solo pueda seleccionar con el DatePicker
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Fecha (DD/MM/AAAA)',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 16),

            // Campo de Porcentaje de Avance
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

            // Campo de Comentario/Descripción
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

            // Checkboxes de Inspección de Calidad
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
                      if (value)
                        _noAprobada =
                            false; // Desmarcar el otro si este se marca
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
                      if (value)
                        _aprobada = false; // Desmarcar el otro si este se marca
                    });
                  },
                ),
                const Text('No Aprobada'),
              ],
            ),
            const SizedBox(height: 24),

            // Botón de Guardar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _guardarAvance,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Registrar Avance',
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
