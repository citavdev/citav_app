import 'dart:convert';
import 'dart:io'; // Importa la biblioteca de manejo de archivos
import 'package:citav_app/entities/apiService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../entities/user.dart';
import '../widgets/app_theme.dart';
import 'package:path_provider/path_provider.dart';
import 'home.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;

Future<void> _fetchData() async {
  const String apiUrl = 'https://ibingcode.com/public/listar5Inspecciones_test';

  try {
    final response = await http.post(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/tus_datos.json';

      // Elimina el archivo existente antes de escribir los nuevos datos
      if (await File(filePath).exists()) {
        await File(filePath).delete();
      }

      // Verifica si el directorio existe, si no, créalo
      if (!(await Directory(directory.path).exists())) {
        await Directory(directory.path).create(recursive: true);
      }

      final file = File(filePath);
      await file.writeAsString(json.encode(jsonData));
    } else {
      print('Error al obtener datos de la API');
    }
  } catch (e) {
    print('Error de conexión: $e');
  }
}


  Future<void> _login(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    const String apiUrl = 'https://ibingcode.com/public/login';

    final Map<String, dynamic> data = {
      'username': _userController.text,
      'password': _passwordController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == true) {
          final userState = Provider.of<User>(context, listen: false);
          userState.updateUser(
            username: jsonResponse['usuario'],
            name: jsonResponse['nombre'],
            id: jsonResponse['cedula'].toString(),
            token: jsonResponse['token'],
          );

          await _fetchData(); // Llama a _fetchData después de iniciar sesión
          await ApiService().fetchDataAndStoreLocally();

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text(
                'Error de inicio de sesión',
                style: TextStyle(fontSize: 24),
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: const Text(
                  'Usuario o contraseña incorrectos.',
                  style: TextStyle(fontSize: 25),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Aceptar',
                    style: TextStyle(fontSize: 25),
                  ),
                ),
              ],
            ),
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error de conexión'),
            content: const Text('No se pudo conectar con el servidor.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Aceptar',
                  style: TextStyle(fontSize: 25),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error de conexión'),
          content: const Text('No se pudo conectar con el servidor.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Aceptar',
                style: TextStyle(fontSize: 25),
              ),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/login_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 100),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(182, 179, 179, 0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    width: 250,
                    height: 250,
                  ),
                  TextFormField(
                    controller: _userController,
                    decoration: const InputDecoration(
                      labelText: 'Usuario',
                      labelStyle: TextStyle(fontSize: 25),
                      hintStyle: TextStyle(fontSize: 50),
                    ),
                    style: const TextStyle(
                      fontSize: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      labelStyle: TextStyle(fontSize: 25),
                    ),
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(height: 50),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 90, vertical: 0),
                    padding: const EdgeInsets.all(20),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (!isLoading)
                          ElevatedButton(
                            onPressed: () => _login(context),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              textStyle: const TextStyle(
                                fontSize: 35,
                              ),
                              backgroundColor: Color(0xFF111D26), // Cambia el color de fondo
                              foregroundColor: Colors.white
                            ),
                            child: const Text('     Iniciar sesión     '),
                          ),
                        if (isLoading)
                          const CircularProgressIndicator(), // Indicador de carga
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
