import 'package:app_construccion/PersonalAsignado/editarpersonal.dart';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class ListaPersonalPage extends StatefulWidget {
  const ListaPersonalPage({super.key});

  @override
  State<ListaPersonalPage> createState() => _ListaPersonalPageState();
}

class _ListaPersonalPageState extends State<ListaPersonalPage> {
  List<Map<String, dynamic>> _personal = [];

  String asistenciaTexto(int valor) {
    return valor == 1 ? 'Asistió' : 'Falta';
  }

  @override
  void initState() {
    super.initState();
    _cargarPersonalA();
  }

  Future<void> _cargarPersonalA() async {
    final db = await DatabaseHelper.instance.database;
    final data = await db.query('personalasignado');
    setState(() {
      _personal = data;
    });
  }

  // Metodo para eliminar registro
  Future<void> _eliminarPersonalA(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar Personal?'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este registro?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final db = await DatabaseHelper.instance.database;
      await db.delete('personalasignado', where: 'id = ?', whereArgs: [id]);
      _cargarPersonalA();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Persona eliminada')));
    }
  }

  Future<void> _editarPersonal(Map<String, dynamic> personal) async {
    final db = await DatabaseHelper.instance.database;
    final obras = await db.query('registroobras');
    final listaObras = obras.map((e) => e['nombre'].toString()).toList();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarPersonalPage(
          personal: personal,
          obrasDisponibles: listaObras,
          onActualizar: (datosActualizados) async {
            await db.update(
              'personalasignado',
              datosActualizados,
              where: 'id = ?',
              whereArgs: [datosActualizados['id']],
            );
            _cargarPersonalA(); // Refresca la lista
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registro actualizado')),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBE6),
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Lista de Personal Registrado'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _personal.isEmpty
          ? const Center(child: Text('No hay personal registrado'))
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _personal.length,
              itemBuilder: (context, index) {
                final personal = _personal[index];

                return Card(
                  color: Colors.orange.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(
                      '${personal['nombreCompleto']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('C.I. ${personal['cedula']}'),
                        Text('Obra: ${personal['nombreObra']}'),
                        Text('Cargo: ${personal['cargo']}'),
                        Text('Teléfono: ${personal['telefono']}'),
                        Text('Tarea: ${personal['tarea']}'),
                        Text(
                          'Asistencia: ${asistenciaTexto(personal['asistencia'])}',
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'editar') {
                          _editarPersonal(personal);
                        } else if (value == 'eliminar') {
                          _eliminarPersonalA(personal['id']);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'editar',
                          child: Text('Editar'),
                        ),
                        const PopupMenuItem(
                          value: 'eliminar',
                          child: Text('Eliminar'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}