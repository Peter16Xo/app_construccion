import 'package:app_construccion/AvanceObra/EditarAvance.dart';
import 'package:app_construccion/AvanceObra/RegistrarAvance.dart';
import 'package:flutter/material.dart';
import 'package:app_construccion/database/database_helper.dart';
// Importar la nueva página de edición

class Avance {
  final int? id;
  final String nombreObra;
  final double porcentaje;
  final String fechaAvance;
  final String comentario; // CAMBIO: Ahora es NOT NULL
  final String inspeccionCalidad; // CAMBIO: Ahora es NOT NULL

  Avance({
    this.id,
    required this.nombreObra,
    required this.porcentaje,
    required this.fechaAvance,
    required this.comentario, // CAMBIO: Ahora es requerido
    required this.inspeccionCalidad, // CAMBIO: Ahora es requerido
  });

  factory Avance.fromMap(Map<String, dynamic> map) {
    return Avance(
      id: map['id'],
      nombreObra: map['nombreObra'] as String, // Asegurar que es String
      porcentaje: map['porcentaje']?.toDouble() ?? 0.0,
      fechaAvance:
          map['fecha'] as String, // CAMBIO: La columna en la BD es 'fecha'
      comentario: map['comentario'] as String, // Asegurar que es String
      inspeccionCalidad:
          map['inspeccionCalidad'] as String, // Asegurar que es String
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombreObra': nombreObra,
      'porcentaje': porcentaje,
      'fechaAvance': fechaAvance,
      'comentario': comentario,
      'inspeccionCalidad': inspeccionCalidad,
    };
  }
}

class AvanceObraPage extends StatefulWidget {
  const AvanceObraPage({super.key});

  @override
  State<AvanceObraPage> createState() => _AvanceObraPageState();
}

class _AvanceObraPageState extends State<AvanceObraPage> {
  late Future<List<Avance>> _avancesFuture;

  @override
  void initState() {
    super.initState();
    _avancesFuture = _loadAvances();
  }

  Future<List<Avance>> _loadAvances() async {
    try {
      final List<Map<String, dynamic>> avancesMapList = await DatabaseHelper
          .instance
          .queryAllAvances();
      print('DEBUG: Datos crudos de queryAllAvances: $avancesMapList'); // DEBUG

      if (avancesMapList.isEmpty) {
        print('DEBUG: queryAllAvances devolvió una lista vacía.'); // DEBUG
        return [];
      }

      final List<Avance> loadedAvances = avancesMapList.map((map) {
        try {
          return Avance.fromMap(map);
        } catch (e) {
          print(
            'DEBUG: Error al mapear Avance desde el mapa: $map, Error: $e',
          ); // DEBUG
          rethrow; // Re-lanza para ver el error original de mapeo
        }
      }).toList();
      print(
        'DEBUG: Se mapearon ${loadedAvances.length} avances correctamente.',
      ); // DEBUG
      return loadedAvances;
    } catch (e) {
      print('DEBUG: Error en _loadAvances: $e'); // DEBUG
      return [];
    }
  }

  void _confirmarEliminacion(int idAvance) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: const Text(
            '¿Estás seguro de que deseas eliminar este avance?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('CANCELAR'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                final messenger = ScaffoldMessenger.of(context);

                await DatabaseHelper.instance.deleteAvance(idAvance);

                if (!mounted) return;

                setState(() {
                  _avancesFuture = _loadAvances();
                });

                if (!mounted) return;
                messenger.showSnackBar(
                  const SnackBar(content: Text('Avance eliminado con éxito')),
                );
              },
              child: const Text('ELIMINAR'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avance de Obra'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: FutureBuilder<List<Avance>>(
        future: _avancesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar los avances: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No hay avances de obra registrados.',
                style: TextStyle(fontSize: 18),
              ),
            );
          } else {
            final List<Avance> avances = snapshot.data!;
            return ListView.builder(
              itemCount: avances.length,
              itemBuilder: (context, index) {
                final avance = avances[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  elevation: 4.0,
                  child: InkWell(
                    // Usamos InkWell para hacer el Card clickeable
                    onTap: () {
                      // Navegar a la pantalla de edición, pasando el avance seleccionado
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditarAvancePage(avance: avance),
                        ),
                      ).then((_) {
                        // Cuando regreses de la pantalla de edición, recarga los avances
                        if (mounted) {
                          setState(() {
                            _avancesFuture = _loadAvances();
                          });
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Obra: ${avance.nombreObra}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Progreso: ${avance.porcentaje.toStringAsFixed(2)}%',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Fecha: ${avance.fechaAvance}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                          if (avance
                              .comentario
                              .isNotEmpty) // No es necesario '!= null' si es String NOT NULL
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Comentario: ${avance.comentario}',
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          if (avance
                              .inspeccionCalidad
                              .isNotEmpty) // No es necesario '!= null' si es String NOT NULL
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Inspección: ${avance.inspeccionCalidad}',
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                if (avance.id != null) {
                                  _confirmarEliminacion(avance.id!);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar a la pantalla de registro de avances.
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RegistrarAvancePage(),
            ),
          ).then((_) {
            // Cuando regreses de la pantalla de registro, recarga los avances
            if (mounted) {
              // Verificar si el widget sigue montado
              setState(() {
                _avancesFuture = _loadAvances();
              });
            }
          });
        },
        child: const Icon(Icons.add),
        tooltip: 'Registrar nuevo avance',
      ),
    );
  }
}