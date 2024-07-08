import 'dart:convert';
import 'dart:io';
import 'package:citav_app/entities/apiService.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

        if (await File(filePath).exists()) {
          await File(filePath).delete();
        }

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

  Future<bool> _login(BuildContext context, {bool validateApi = true}) async {
    setState(() {
      isLoading = true;
    });

    final String apiUrl = 'https://ibingcode.com/public/login';

    Map<String, dynamic> data;

    if (validateApi) {
      data = {
        'username': _userController.text,
        'password': _passwordController.text,
      };
    } else {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      data = {
        'username': prefs.getString('username') ?? '',
        'password': prefs.getString('password') ?? '',
      };
    }

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
            password: jsonResponse['password'],
          );

          if (validateApi) {
            await _saveCredentialsLocally(
              username: jsonResponse['usuario'],
              name: jsonResponse['nombre'],
              id: jsonResponse['cedula'].toString(),
              token: jsonResponse['token'],
              password: jsonResponse['password'],
            );
          }

          await _fetchData();
          await ApiService().fetchDataAndStoreLocally();

          return true;
        } else {
          _showErrorDialog(context, 'Usuario o contraseña incorrectos.');
          return false;
        }
      } else {
        _showErrorDialog(context, 'No se pudo conectar con el servidor.');
        return false;
      }
    } catch (e) {
      if (validateApi) {
        if (e is SocketException) {
          print('No hay conexión a Internet. Iniciar sesión con datos locales.');
          return false;
        } else {
          print('Error al conectar con el servidor. Error: $e');
          return false;
        }
      } else {
        print('Error al conectar con el servidor. Error: $e');
        return false;
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveCredentialsLocally({
    required String username,
    required String name,
    required String id,
    required String token,
    required String password,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('username', username);
    prefs.setString('name', name);
    prefs.setString('id', id);
    prefs.setString('token', token);
    prefs.setString('password', password);
  }

  Future<void> _tryLoginWithStoredCredentials(BuildContext context) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final storedUsername = prefs.getString('username');
  final storedPassword = prefs.getString('password');

  if (storedUsername != null && storedPassword != null) {
    setState(() {
      _userController.text = storedUsername;
      _passwordController.text = storedPassword;
      isLoading = true;
    });

    print('Trying to login with stored credentials...');
    bool success = await _login(context, validateApi: false);

    setState(() {
      isLoading = false;
    });

    if (success) {
      print('Login with stored credentials completed.');
    } else {
      print('Login with stored credentials failed.');
      _showErrorDialog(context, 'No se pudo iniciar sesión con los datos locales.');
    }
  } else {
    print('No stored credentials found.');
  }
}


  Future<bool> _checkInternetConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }


  Future<void> _checkInternetAndLogin(BuildContext context) async {
  bool hasInternet = await _checkInternetConnectivity();
  if (hasInternet) {
    await _tryLoginWithStoredCredentials(context);
  } else {
    _showStoredCredentialsDialog(context);
  }
}


  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Error de inicio de sesión',
          style: TextStyle(fontSize: 24),
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: Text(
            message,
            style: const TextStyle(fontSize: 25),
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

  void _showStoredCredentialsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Datos almacenados localmente',
          style: TextStyle(fontSize: 24),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Usuario: ${_userController.text}'),
            Text('Contraseña: ${_passwordController.text}'),
          ],
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

  @override
  void initState() {
    super.initState();
    _checkInternetAndLogin(context);
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
                              backgroundColor: Color(0xFF111D26),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('     Iniciar sesión     '),
                          ),
                        if (isLoading)
                          const CircularProgressIndicator(),
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
