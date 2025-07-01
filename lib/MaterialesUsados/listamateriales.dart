import 'package:flutter/material.dart';
import 'editarmateriales.dart';

class ListaMaterialesPage extends StatefulWidget {
  final List<Map<String, dynamic>> materiales;

  const ListaMaterialesPage({super.key, required this.materiales});

  @override
  State<ListaMaterialesPage> createState() => _ListaMaterialesPageState();
}

class _ListaMaterialesPageState extends State<ListaMaterialesPage> {
  String _formatFecha(DateTime? fecha) {
    if (fecha == null) return 'Sin fecha';
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  void _editarMaterial(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditarMaterialPage(
          material: widget.materiales[index],
          onActualizar: (materialActualizado) {
            setState(() {
              widget.materiales[index] = materialActualizado;
            });
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

  void _eliminarMaterial(int index) async {
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
      setState(() => widget.materiales.removeAt(index));
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
      body: widget.materiales.isEmpty
          ? const Center(child: Text('No hay materiales registrados'))
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: widget.materiales.length,
              itemBuilder: (context, index) {
                final material = widget.materiales[index];
                return Card(
                  color: Colors.orange.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(
                      '${material['material']} (Material #${material['numero']})',
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Obra: ${material['obra']['nombre']}'),
                        Text('Cantidad: ${material['cantidad']}'),
                        Text('Costo: \$${material['costo']}'),
                        Text(
                          'Fecha de uso: ${_formatFecha(material['fechaUso'])}',
                        ),
                        Text('Observaciones: ${material['observaciones']}'),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'editar') {
                          _editarMaterial(index);
                        } else if (value == 'eliminar') {
                          _eliminarMaterial(index);
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
