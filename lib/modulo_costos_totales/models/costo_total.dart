
class CostoTotal {
  String idObra;
  double presupuesto;
  double materiales;
  double manoObra;
  double herramientas;
  double otros;

  CostoTotal({
    required this.idObra,
    required this.presupuesto,
    required this.materiales,
    required this.manoObra,
    required this.herramientas,
    required this.otros,
  });

  double get totalGastado => materiales + manoObra + herramientas + otros;
  double get diferencia => presupuesto - totalGastado;
}
