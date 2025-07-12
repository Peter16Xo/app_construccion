import 'package:flutter/material.dart';
import '../database/database_helper.dart';


class ListaObrasPage extends StatefulWidget {
  const ListaObrasPage({super.key});

  @override
  State<ListaObrasPage> createState() => _ListaObrasPageState();
}

class _ListaObrasPageState extends State<ListaObrasPage> {
  List<Map<String, dynamic>> _obras = [];

  @override
  void initState() {
    super.initState();
    _cargarObras();
  }

  Future<void> _cargarObras() async {
    final db = await DatabaseHelper.instance.database;
    final data = await db.query('registroobras');
    setState(() {
      _obras = data;
    });
  }

  Future<void> _eliminarObra(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar obra?'),
        content: const Text('¿Estás seguro de que deseas eliminar esta obra?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );

    if (confirm == true) {
      final db = await DatabaseHelper.instance.database;
      await db.delete('registroobras', where: 'id = ?', whereArgs: [id]);
      _cargarObras();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Obra eliminada')),
      );
    }
  }

  Future<void> _editarObra(Map<String, dynamic> obra) async {
  }

  String formatFecha(String fechaIso) {
    final fecha = DateTime.tryParse(fechaIso);
    if (fecha == null) return 'Sin fecha';
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBE6),
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Lista de Obras Registradas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _obras.isEmpty
          ? const Center(child: Text('No hay obras registradas'))
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _obras.length,
              itemBuilder: (context, index) {
                final obra = _obras[index];

                return Card(
                  color: Colors.orange.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(
                      '${obra['nombre']} (ID #${obra['id']})',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cliente: ${obra['cliente']}'),
                        Text('Ubicación: ${obra['ubicacion']}'),
                        Text('Inicio: ${formatFecha(obra['fechaInicio'])}'),
                        Text('Fin: ${formatFecha(obra['fechaFin'])}'),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'editar') {
                          _editarObra(obra);
                        } else if (value == 'eliminar') {
                          _eliminarObra(obra['id']);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'editar', child: Text('Editar')),
                        const PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
