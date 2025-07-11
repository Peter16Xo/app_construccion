import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'editarmateriales.dart';

class ListaMaterialesPage extends StatefulWidget {
  const ListaMaterialesPage({super.key});

  @override
  State<ListaMaterialesPage> createState() => _ListaMaterialesPageState();
}

class _ListaMaterialesPageState extends State<ListaMaterialesPage> {
  List<Map<String, dynamic>> _materiales = [];

  @override
  void initState() {
    super.initState();
    _cargarMateriales();
  }

  Future<void> _cargarMateriales() async {
    final db = await DatabaseHelper.instance.database;
    final data = await db.rawQuery('registromateriales');

    setState(() {
      _materiales = data;
    });
  }

  String _formatFecha(String fechaIso) {
    final fecha = DateTime.tryParse(fechaIso);
    if (fecha == null) return 'Sin fecha';
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  Future<void> _editarMaterial(Map<String, dynamic> material) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditarMaterialPage(
          material: material,
          onActualizar: (materialActualizado) async {
            final db = await DatabaseHelper.instance.database;
            await db.update(
              'materialesusados',
              {
                'nombre': materialActualizado['nombre'],
                'cantidad': materialActualizado['cantidad'],
                'costoUnitario': materialActualizado['costoUnitario'],
                'fechaUso': materialActualizado['fechaUso'],
                'observaciones': materialActualizado['observaciones'],
              },
              where: 'id = ?',
              whereArgs: [material['id']],
            );
            _cargarMateriales();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Material actualizado correctamente'),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _eliminarMaterial(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Eliminar Material?'),
        content: const Text('¿Seguro que deseas eliminar este material?'),
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
      await db.delete('materialesusados', where: 'id = ?', whereArgs: [id]);
      _cargarMateriales();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Material eliminado')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBE6),
      appBar: AppBar(
        title: const Text('Lista de Materiales Usados'),
        backgroundColor: const Color(0xFFFFFBE6),
        foregroundColor: Colors.black,
      ),
      body: _materiales.isEmpty
          ? const Center(child: Text('No hay materiales registrados'))
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _materiales.length,
              itemBuilder: (context, index) {
                final material = _materiales[index];

                return Card(
                  color: Colors.orange.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(
                      '${material['nombre']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Obra: ${material['nombreObra']} - ${material['clienteObra']}',
                        ),
                        Text('Cantidad: ${material['cantidad']}'),
                        Text('Costo: \$${material['costoUnitario']}'),
                        Text(
                          'Fecha de uso: ${_formatFecha(material['fechaUso'])}',
                        ),
                        Text(
                          'Observaciones: ${material['observaciones'] ?? ''}',
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'editar') {
                          _editarMaterial(material);
                        } else if (value == 'eliminar') {
                          _eliminarMaterial(material['id']);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'editar', child: Text('Editar')),
                        PopupMenuItem(
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