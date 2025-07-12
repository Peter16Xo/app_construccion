import 'package:app_construccion/PersonalAsignado/registrarpersonal.dart';
import 'package:flutter/material.dart';
import 'RegistrObra/registrarobra.dart';
import 'avanceObra.dart';
import 'MaterialesUsados/registrarmaterialesusados.dart';
import 'costosTotales.dart';
import 'login.dart';

class MyHomePageVentanaPrincipal extends StatefulWidget {
  const MyHomePageVentanaPrincipal({super.key});

  @override
  State<MyHomePageVentanaPrincipal> createState() =>
      _MyHomePageVentanaPrincipalState();
}

class _MyHomePageVentanaPrincipalState
    extends State<MyHomePageVentanaPrincipal> {
  int currentPageIndex = 0;

  List<Map<String, dynamic>> obras = [];

  List<Widget> get _pages => [
    RegistrarObraPage(
      obras: obras,
      onObrasChanged: (nuevaLista) {
        setState(() {
          obras = nuevaLista;
        });
      },
    ),
    AvanceObraPage(),
    RegistrarMaterialesUsadosPage(obras: obras),
    RegistrarPersonalPage(),
    CostosTotalesPage(),
  ];

  void _mostrarDialogo(String titulo, String contenido) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(contenido),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AppConstrucción'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'acerca':
                  _mostrarDialogo(
                    'Acerca De',
                    'Versión 1.0\nDesarrollado por Grupo #4',
                  );
                  break;
                case 'ayuda':
                  _mostrarDialogo(
                    'Ayuda',
                    'Navega entre secciones con la barra inferior.\nRegistra datos correctamente.',
                  );
                  break;
                case 'config':
                  _mostrarDialogo(
                    'Configuración',
                    'Configuración aún no disponible.',
                  );
                  break;
                case 'cerrar':
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'acerca', child: Text('Acerca De')),
              PopupMenuItem(value: 'ayuda', child: Text('Ayuda')),
              PopupMenuItem(value: 'config', child: Text('Configuración')),
              PopupMenuItem(value: 'cerrar', child: Text('Cerrar Sesión')),
            ],
          ),
        ],
      ),
      body: _pages[currentPageIndex],
      bottomNavigationBar: NavigationBar(
        height: 70,
        indicatorColor: Theme.of(
          context,
        ).colorScheme.secondary.withOpacity(0.2),
        selectedIndex: currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.construction_outlined),
            selectedIcon: Icon(Icons.construction),
            label: 'Registrar',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up_outlined),
            selectedIcon: Icon(Icons.trending_up),
            label: 'Avance',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_outlined),
            selectedIcon: Icon(Icons.inventory),
            label: 'Materiales',
          ),
          NavigationDestination(
            icon: Icon(Icons.group_outlined),
            selectedIcon: Icon(Icons.group),
            label: 'Personal',
          ),
          NavigationDestination(
            icon: Icon(Icons.attach_money_outlined),
            selectedIcon: Icon(Icons.attach_money),
            label: 'Costos',
          ),
        ],
      ),
    );
  }
}
