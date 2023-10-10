import 'package:flutter/material.dart';

class AppTheme {

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
     appBarTheme: const AppBarTheme(
       backgroundColor: Color(0xFF111D26), // Color de la AppBar
        
    ),
    
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 25.0, color: primaryTextColor),
      bodyMedium: TextStyle(fontSize: 14.0),
      // ... otros estilos de fuente
    ),
    // ... otros atributos de ThemeData
  );

  static const Color primaryTextColor = darkColor2;
  static const Color secondaryTextColor = Colors.grey;

  static const Color asentColor1 = Color.fromRGBO(244,157,76,1);  
  static const Color asentColor2 = Color.fromRGBO(255,74,23,1);

  static const Color darkColor1 = Color.fromRGBO(45,59,69,1);
  static const Color darkColor2 = Color.fromRGBO(21,34,43,1);

  static const Color lightColor1 = Color.fromRGBO(255, 255, 255, 1);
  static const Color lightColor2 = Color.fromRGBO(236, 232, 232, 1);
  // ... otros colores y estilos

  final TextStyle bodyLargeStyle = const TextStyle(fontSize: 25.0, color: primaryTextColor);
  final TextStyle bodyMediumStyle = const TextStyle(fontSize: 14.0);

  final TextStyle textButton1 = const TextStyle(fontSize: 30.0, color: Color.fromARGB(255, 255, 255, 255));
 final ButtonStyle buttonLightStyle = ElevatedButton.styleFrom(
    backgroundColor:  const Color.fromRGBO(244,157,76,1),
    foregroundColor: Colors.white, // Color de fondo del botón
    // Estilo de texto
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Padding interno
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0), // Borde redondeado
    ),
  );

  final ButtonStyle buttonDarkStyle = ElevatedButton.styleFrom(
    backgroundColor:  const Color(0xFF111D26),
    foregroundColor: Colors.white, // Color de fondo del botón
    // Estilo de texto
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Padding interno
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0), // Borde redondeado
    ),
  );
}
