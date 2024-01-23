import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String apiUrl = "https://ibingcode.com/public/getmarcas";
  static const String localFileName = "marcas_data.json";

  Future<void> fetchDataAndStoreLocally() async {
    try {
      // Realizar la solicitud HTTP
      final response = await http.get(Uri.parse(apiUrl));

      // Verificar si la solicitud fue exitosa (código de respuesta 200)
      if (response.statusCode == 200) {
        // Decodificar el JSON obtenido
        List<dynamic> newData = json.decode(response.body);

        // Obtener los datos almacenados localmente
        List<dynamic> existingData = await loadDataLocally();

        // Comparar los datos y actualizar si es necesario
        if (!areDataEqual(existingData, newData)) {
          // Almacenar los datos localmente utilizando shared_preferences y guardar en archivo
          await storeDataLocally(newData);
        } else {
          print("Los datos locales ya están actualizados.");
        }
      } else {
        // Manejar el error si la solicitud no fue exitosa
        print("Error en la solicitud HTTP: ${response.statusCode}");
      }
    } catch (e) {
      // Manejar cualquier excepción que pueda ocurrir
      print("Error al realizar la solicitud HTTP: $e");
    }
  }

  Future<List<dynamic>> loadDataLocally() async {
    try {
      // Obtener una instancia de SharedPreferences
      final prefs = await SharedPreferences.getInstance();

      // Obtener la cadena JSON almacenada
      String? jsonString = prefs.getString('marcas_data');

      // Si no hay datos almacenados en SharedPreferences, cargar desde el archivo
      if (jsonString == null) {
        jsonString = await _loadDataFromFile();
      }

      // Decodificar la cadena JSON a una lista de datos
      List<dynamic> data = json.decode(jsonString);

      return data;
    } catch (e) {
      // Manejar cualquier excepción que pueda ocurrir al cargar datos
      print("Error al cargar datos localmente: $e");
      return [];
    }
  }

  Future<String> _loadDataFromFile() async {
    try {
      // Obtener el directorio de documentos de la aplicación
      Directory appDocDir = await getApplicationDocumentsDirectory();

      // Construir la ruta completa del archivo
      String filePath = '${appDocDir.path}/$localFileName';

      // Leer el contenido del archivo
      File file = File(filePath);
      if (await file.exists()) {
        return await file.readAsString();
      } else {
        // Si el archivo no existe, devolver una cadena vacía
        return '';
      }
    } catch (e) {
      // Manejar cualquier excepción que pueda ocurrir al leer datos desde el archivo
      print("Error al leer datos desde el archivo: $e");
      return '';
    }
  }

  Future<void> storeDataLocally(List<dynamic> data) async {
    try {
      // Obtener una instancia de SharedPreferences
      final prefs = await SharedPreferences.getInstance();

      // Convertir la lista de datos a una cadena JSON y almacenarla
      prefs.setString('marcas_data', json.encode(data));

      // Almacenar los datos también en el archivo
      await _saveDataToFile(json.encode(data));

      print("Datos almacenados localmente con éxito.");
    } catch (e) {
      // Manejar cualquier excepción que pueda ocurrir al almacenar datos localmente
      print("Error al almacenar datos localmente: $e");
    }
  }

  Future<void> _saveDataToFile(String data) async {
    try {
      // Obtener el directorio de documentos de la aplicación
      Directory appDocDir = await getApplicationDocumentsDirectory();

      // Construir la ruta completa del archivo
      String filePath = '${appDocDir.path}/$localFileName';

      // Escribir el contenido en el archivo
      File file = File(filePath);
      await file.writeAsString(data);

      print("Datos guardados en el archivo con éxito.");
    } catch (e) {
      // Manejar cualquier excepción que pueda ocurrir al escribir datos en el archivo
      print("Error al escribir datos en el archivo: $e");
    }
  }

  bool areDataEqual(List<dynamic> existingData, List<dynamic> newData) {
    // Compara si los datos existentes y nuevos son iguales
    return json.encode(existingData) == json.encode(newData);
  }
}
