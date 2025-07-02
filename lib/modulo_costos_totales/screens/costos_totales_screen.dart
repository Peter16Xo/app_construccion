import 'package:flutter/material.dart';
import '../models/costo_total.dart';
import '../widgets/campo_texto.dart';

class CostosTotalesScreen extends StatefulWidget {
  @override
  _CostosTotalesScreenState createState() => _CostosTotalesScreenState();
}

class _CostosTotalesScreenState extends State<CostosTotalesScreen> {
  final TextEditingController idObraController = TextEditingController();
  final TextEditingController presupuestoController = TextEditingController();
  final TextEditingController materialesController = TextEditingController();
  final TextEditingController manoObraController = TextEditingController();
  final TextEditingController herramientasController = TextEditingController();
  final TextEditingController otrosController = TextEditingController();

  List<CostoTotal> listaCostos = [];
  int? indexEditando;

  void guardarRegistro() {
    final nuevo = CostoTotal(
      idObra: idObraController.text,
      presupuesto: double.tryParse(presupuestoController.text) ?? 0,
      materiales: double.tryParse(materialesController.text) ?? 0,
      manoObra: double.tryParse(manoObraController.text) ?? 0,
      herramientas: double.tryParse(herramientasController.text) ?? 0,
      otros: double.tryParse(otrosController.text) ?? 0,
    );

    setState(() {
      if (indexEditando == null) {
        listaCostos.add(nuevo);
      } else {
        listaCostos[indexEditando!] = nuevo;
      }
      limpiarCampos();
    });
  }

  void editarRegistro(int index) {
    final c = listaCostos[index];
    idObraController.text = c.idObra;
    presupuestoController.text = c.presupuesto.toString();
    materialesController.text = c.materiales.toString();
    manoObraController.text = c.manoObra.toString();
    herramientasController.text = c.herramientas.toString();
    otrosController.text = c.otros.toString();
    setState(() {
      indexEditando = index;
    });
  }

  void eliminarRegistro(int index) {
    setState(() {
      listaCostos.removeAt(index);
      limpiarCampos();
    });
  }

  void limpiarCampos() {
    idObraController.clear();
    presupuestoController.clear();
    materialesController.clear();
    manoObraController.clear();
    herramientasController.clear();
    otrosController.clear();
    indexEditando = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Costos Totales'),
        backgroundColor: const Color.fromRGBO(247, 245, 245, 1),
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            campoTexto("ID Obra", idObraController),
            campoTexto("Presupuesto", presupuestoController),
            campoTexto("Materiales", materialesController),
            campoTexto("Mano de Obra", manoObraController),
            campoTexto("Herramientas", herramientasController),
            campoTexto("Otros", otrosController),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: guardarRegistro,
                  icon: const Icon(Icons.save),
                  label: Text(indexEditando == null ? 'Guardar' : 'Actualizar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 141, 233, 144),
                    foregroundColor: Colors.black,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: limpiarCampos,
                  icon: const Icon(Icons.clear),
                  label: const Text('Limpiar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 90, 40),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: listaCostos.length,
                itemBuilder: (context, index) {
                  final c = listaCostos[index];
                  return Card(
                    color: Colors.grey[100],
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text("Obra: ${c.idObra}",
                          style: const TextStyle(color: Colors.black)),
                      subtitle: Text(
                        "Total: \$${c.totalGastado.toStringAsFixed(2)} | Dif: \$${c.diferencia.toStringAsFixed(2)}",
                        style: TextStyle(
                          color: c.diferencia >= 0
                              ? Colors.green
                              : const Color.fromARGB(255, 244, 108, 54),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Wrap(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => editarRegistro(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => eliminarRegistro(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
