import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../entities/user.dart';
import '../pages/login.dart';
import 'app_theme.dart';

class DrawerPage extends StatelessWidget {
  const DrawerPage({super.key});

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppTheme.asentColor1,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Image(
                  image: AssetImage('assets/logo.png'),
                  width: 100,
                  height: 100,
                ),
                const SizedBox(
                    height: 5), // Espacio entre la imagen y el texto adicional
                Text(
                  user.name.toString().toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title:
                Text('Inicio', style: AppTheme.lightTheme.textTheme.bodyLarge),
            onTap: () {
              Navigator.of(context).pop(); // Cerrar el Drawer
              Navigator.pushNamed(context, '/home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Sincronizar'),
            enabled: false,
            onTap: () {
              // Lógica para sincronizar
              Navigator.of(context).pop(); // Cerrar el Drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Nueva Inspección'),
            onTap: () {
              Navigator.of(context).pop(); // Cerrar el Drawer
              Navigator.pushNamed(context, '/inspection');
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Inspec. Realizadas'),
            enabled: true,
            onTap: () {
              Navigator.of(context).pop(); // Cerrar el Drawer
              Navigator.pushNamed(context, '/my_inspections');
            },
          ),

          

          const SizedBox(height: 50),
          const Divider(), // Línea divisora
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar Sesión'),
            onTap: () {
              // Lógica para cerrar sesión
              Navigator.of(context).pop(); // Cerrar el Drawer
              // Navegar a la página de login, asegurándonos de que no se pueda volver atrás
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginPage()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
