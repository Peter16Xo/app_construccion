import 'package:flutter/material.dart';
import 'editarObra.dart';

class ListaObrasPage extends StatefulWidget {
  final List<Map<String, dynamic>> obras;

  const ListaObrasPage({super.key, required this.obras});

  @override
  State<ListaObrasPage> createState() => _ListaObrasPageState();
}

class _ListaObrasPageState extends State<ListaObrasPage> {
  void _eliminarObra(int index) async {
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
      setState(() {
        widget.obras.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Obra eliminada')),
      );
    }
  }

  void _editarObra(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarObraPage(
          obra: widget.obras[index],
          onActualizar: (obraActualizada) {
            setState(() {
              widget.obras[index] = obraActualizada;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Obra actualizada correctamente')),
            );
          },
        ),
      ),
    );
  }

  String formatFecha(DateTime? fecha) {
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
      body: widget.obras.isEmpty
          ? const Center(child: Text('No hay obras registradas'))
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: widget.obras.length,
              itemBuilder: (context, index) {
                final obra = widget.obras[index];

                return Card(
                  color: Colors.orange.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(
                      '${obra['nombre']} (Obra #${obra['numero']})',
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
                          _editarObra(index);
                        } else if (value == 'eliminar') {
                          _eliminarObra(index);
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
