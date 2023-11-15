import 'package:citav_app/pages/atypical_inspection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'new_inspection.dart';
import '../widgets/app_theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FindPlatePage extends StatefulWidget {
  const FindPlatePage({super.key});

  @override
  _FindPlatePageState createState() => _FindPlatePageState();
}

class _FindPlatePageState extends State<FindPlatePage> {
  final TextEditingController _plateController = TextEditingController();
  bool _isPlateEmpty = true;

  void _navigateToNewInspectionWithData(String plate) async {
    try {
      final response = await http.post(
        Uri.parse('https://ibingcode.com/public/infovehiculo'),
        body: '{"placa": "$plate"}',
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          _showErrorMessage(
              'Vehículo no encontrado en la base de datos del RUNT.');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AtypicalInspection(
                plateValue: plate,
              ),
            ),
          );
        } else {
          final List<dynamic> data = json.decode(response.body);

          if (data.isNotEmpty) {
            final Map<String, dynamic> vehicleData = data[0];

            String modelo = vehicleData['v.modelo'];
            String numeroChasis = vehicleData['numero_chasis'];
            String numeroMotor = vehicleData['numero_motor'];
            String marca = vehicleData['marca'];
            String tipoServicio = vehicleData['tipo_servicio'];
            String tipoVehiculo = vehicleData['tipo_vehiculo'];
            String organismoTransito = vehicleData['organismo_transito'];
            String idPropietario = vehicleData['id_propietario'].toString();
            String nombrePropietario = vehicleData['nombre_propietario'];

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => NewInspection(
                    plateValue: plate,
                    modelo: modelo,
                    numeroChasis: numeroChasis,
                    numeroMotor: numeroMotor,
                    marca: marca,
                    tipoServicio: tipoServicio,
                    tipoVehiculo: tipoVehiculo,
                    organismoTransito: organismoTransito,
                    idPropietario: idPropietario,
                    nombrePropietario: nombrePropietario),
              ),
            );
          } else {
            _showErrorMessage(
                'Vehículo no encontrado en la base de datos del RUNT.');
                          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AtypicalInspection(
                plateValue: plate,
              ),
            ),
          );
          }
        }
      } else {
        _showErrorMessage(
            'No se pudo obtener información del vehículo. Sin conexión con el servidor.');
            Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AtypicalInspection(
                plateValue: plate,
              ),
            ),
          );
      }
    } catch (e) {
      _showErrorMessage(
          'Error al comunicarse con el servidor. Verifique su conexión a internet.$e');
                    Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AtypicalInspection(
                plateValue: plate,
              ),
            ),
          );
    }
  }

  void _showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error', style: TextStyle(fontSize: 25.0)),
        content: Text(message, style: const TextStyle(fontSize: 25.0)),
        actions: <Widget>[
          TextButton(
            child: const Text('Aceptar', style: TextStyle(fontSize: 25.0)),
            onPressed: () {
              Navigator.of(context).pop(); // Cierra la ventana emergente
            },
          ),
        ],
      ),
    );
  }

  void _validateAndNavigate() async {
    final plate = _plateController.text;

    if (plate.length != 6) {
      _showErrorMessage('La placa debe tener exactamente 6 caracteres.');
    } else {
      try {
        final validationResponse = await http.post(
          Uri.parse('https://ibingcode.com/public/consultarplacas'),
          body: '{"placa": "$plate"}',
          headers: {'Content-Type': 'application/json'},
        );

        if (validationResponse.statusCode == 200) {
          final validationData = validationResponse.body;

          if (validationData.toLowerCase() == 'true') {
            _showErrorMessage('Ya existe una inspección registrada con esta placa.');
          } else {
            _navigateToNewInspectionWithData(plate);
          }
        } else {
          _showErrorMessage(
              'No se pudo validar la placa. Sin conexión con el servidor.');
        }
      } catch (e) {
        _showErrorMessage(
            'Error al comunicarse con el servidor de validación. Verifique su conexión a internet.$e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _plateController.addListener(_updatePlateEmptyStatus);
  }

  void _updatePlateEmptyStatus() {
    setState(() {
      _isPlateEmpty = _plateController.text.trim().isEmpty;
    });
  }

  @override
  void dispose() {
    _plateController.removeListener(_updatePlateEmptyStatus);
    _plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/fondo6.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: SizedBox(
                  width: 450,
                  child: TextField(
                    controller: _plateController,
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(6),
                      UpperCaseTextFormatter(),
                    ],
                    decoration: const InputDecoration(
                      hintText: 'INGRESE LA PLACA DEL VEHÍCULO',
                    ),
                    style: const TextStyle(fontSize: 25.0),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              style: AppTheme().buttonLightStyle,
              onPressed: _isPlateEmpty ? null : _validateAndNavigate,
              child: const Text('Inspeccionar', style: TextStyle(fontSize: 25.0)
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
        text: newValue.text.toUpperCase(), selection: newValue.selection);
  }
}
