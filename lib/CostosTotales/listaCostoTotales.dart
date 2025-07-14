import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'registrarCostosTotales.dart';
import 'editarCostoTotales.dart';

class ListaCostosTotalesPage extends StatefulWidget {
  const ListaCostosTotalesPage({super.key});

  @override
  State<ListaCostosTotalesPage> createState() => _ListaCostosTotalesPageState();
}

class _ListaCostosTotalesPageState extends State<ListaCostosTotalesPage> {
  List<Map<String, dynamic>> _costos = [];

  @override
  void initState() {
    super.initState();
    _cargarCostos();
  }

  Future<void> _cargarCostos() async {
    final db = await DatabaseHelper.instance.database;
    final data = await db.rawQuery('''
      SELECT c.*, o.nombre as nombreObra
      FROM costostotales c
      JOIN registroobras o ON c.idObra = o.id
      ORDER BY c.fechaRegistro DESC
    ''');
    setState(() => _costos = data);
  }

  void _abrirRegistrar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegistrarCostosTotalesPage(onGuardado: _cargarCostos),
      ),
    );
  }

  void _editarCosto(Map<String, dynamic> costo) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            EditarCostosTotalesPage(costo: costo, onActualizado: _cargarCostos),
      ),
    );
  }

  Future<void> _eliminarCosto(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Eliminar Costo Total?'),
        content: const Text('¿Estás seguro de eliminar este registro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      final db = await DatabaseHelper.instance.database;
      await db.delete('costostotales', where: 'id = ?', whereArgs: [id]);
      _cargarCostos();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Registro eliminado')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Costos Totales'),
        backgroundColor: const Color(0xFFFFFBE6),
        foregroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFFFFFBE6),
      body: _costos.isEmpty
          ? const Center(child: Text('No hay registros'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _costos.length,
              itemBuilder: (context, index) {
                final costo = _costos[index];
                final totalGastado =
                    (costo['montoMateriales'] ?? 0) +
                    (costo['montoManoObra'] ?? 0) +
                    (costo['montoHerramientas'] ?? 0) +
                    (costo['montoOtras'] ?? 0);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(
                      costo['nombreObra'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Presupuesto: \$${costo['presupuesto'].toStringAsFixed(2)}',
                        ),
                        Text(
                          'Materiales: \$${costo['montoMateriales'].toStringAsFixed(2)}',
                        ),
                        Text(
                          'Total gastado: \$${totalGastado.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'editar') _editarCosto(costo);
                        if (value == 'eliminar') _eliminarCosto(costo['id']);
                      },
                      itemBuilder: (_) => [
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
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirRegistrar,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}