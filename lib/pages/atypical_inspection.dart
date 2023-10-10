import 'dart:convert';
import 'package:citav_app/pages/find_plate.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../entities/user.dart';
import 'package:http/http.dart' as http;

import '../widgets/app_theme.dart';

class AtypicalInspection extends StatefulWidget {
  final String plateValue;

  const AtypicalInspection({
    required this.plateValue,
  });

  @override
  _AtypicalInspectionState createState() => _AtypicalInspectionState();
}

class _AtypicalInspectionState extends State<AtypicalInspection> {
  Location location = Location();
  double? latitude;
  double? longitude;
  DateTime? selectedDate;
  String fechaIngreso = "";
  List<File?> photos = List.generate(4, (_) => null);
  List<FileInfo?> photosInfo = List.generate(4, (_) => null);

  String selectedVehicleType = 'Automovil';
  String selectedCarBrand = 'Toyota';

  List<String> vehicleTypes = [
    'Automovil',
    'Bus',
    'Camioneta',
    'Motocicleta',
    'TractoCamion',
    'otros',
  ];

  List<String> carBrands = [
    'Alfa Romeo',
    'Audi',
    'BMW',
    'Cadillac',
    'Chevrolet',
    'Chrysler',
    'Citroën',
    'Dodge',
    'Fiat',
    'Ford',
    'Honda',
    'Hyundai',
    'Jaguar',
    'Jeep',
    'Kia',
    'Land Rover',
    'Mazda',
    'Mercedes-Benz',
    'Mini',
    'Mitsubishi',
    'Nissan',
    'Peugeot',
    'Porsche',
    'Ram',
    'Renault',
    'Subaru',
    'Suzuki',
    'Toyota',
    'Volkswagen',
    'Volvo',
    'otros'
    // Agrega aquí las demás marcas de carros
  ];

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    LocationData _locationData = await location.getLocation();
    if (mounted) {
      setState(() {
        latitude = _locationData.latitude;
        longitude = _locationData.longitude;
      });
    }
  }

  Future<void> _takePhoto(int photoIndex) async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);

      final int fileSizeInBytes = imageFile.lengthSync();
      final double fileSizeInKB = fileSizeInBytes / 1024.0;
      final String imageDimensions =
          '${imageFile.readAsBytesSync().lengthInBytes}x${imageFile.readAsBytesSync().lengthInBytes}';

      final FileInfo fileInfo = FileInfo(
        file: imageFile,
        sizeInKB: fileSizeInKB,
        dimensions: imageDimensions,
      );

      setState(() {
        photos[photoIndex] = imageFile;
        photosInfo[photoIndex] = fileInfo;
      });
    }
  }

  Widget _buildPhoto(int photoIndex) {
  final photo = photos[photoIndex];

  return Column(
    children: [
      photo != null
          ? Image.file(
              photo,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            )
          : Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF111D26),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: InkWell(
                onTap: () => _takePhoto(photoIndex),
                child: Center(
                  child: Icon(
                    Icons.camera_alt, // Cambia a tu icono deseado
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
    ],
  );
}

  @override
  Widget build(BuildContext context) {
    String firstPart = widget.plateValue.substring(0, 3);
    String secondPart = widget.plateValue.substring(3, 6);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inspección sin información del RUNT',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'assets/placa.png',
                      width: 350,
                      height: 200,
                    ),
                    Positioned(
                      left: 25,
                      child: SizedBox(
                        width: 150,
                        child: Text(
                          firstPart,
                          style: const TextStyle(
                            fontFamily: 'Roboto Mono',
                            fontSize: 68,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 2,
                      child: SizedBox(
                        width: 150,
                        child: Text(
                          secondPart,
                          style: const TextStyle(
                            fontSize: 68,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      DropdownButton<String>(
                        isExpanded: true,
                        value: selectedVehicleType,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedVehicleType = newValue!;
                          });
                        },
                        items: vehicleTypes.map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                      ),
                      DropdownButton<String>(
                        isExpanded: true,
                        value: selectedCarBrand,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCarBrand = newValue!;
                          });
                        },
                        items: carBrands.map((String brand) {
                          return DropdownMenuItem<String>(
                            value: brand,
                            child: Text(brand),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          return _buildPhoto(index);
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          style: AppTheme().buttonLightStyle,
                          onPressed: () {
                            _sendDataToAPI();
                          },
                          child: const Text(
                            'Enviar Inspección',
                            style: TextStyle(fontSize: 35),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendDataToAPI() async {
    final user = Provider.of<User>(context, listen: false);
    final DateTime currentDate = DateTime.now();
    final String formattedDate =
        "${currentDate.year}-${currentDate.month}-${currentDate.day}";

    bool allPhotosTaken = true;
    for (int i = 0; i < photos.length; i++) {
      if (photos[i] == null) {
        allPhotosTaken = false;
        break;
      }
    }

    if (!allPhotosTaken) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error', style: TextStyle(fontSize: 25.0)),
          content: const Text(
            'Para continuar, por favor tome el registro fotográfico completo.',
            style: TextStyle(fontSize: 25.0),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Aceptar', style: TextStyle(fontSize: 25.0)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
      return;
    }

    var postUri = Uri.parse('https://ibingcode.com/public/subirinspeccion');
    http.MultipartRequest request = http.MultipartRequest("POST", postUri);
    final Map<String, String> data = {
      "placa": widget.plateValue,
      "fecha_inspeccion": formattedDate,
      "fecha_ingreso": "",
      "estado": "1",
      "id_funcionario": user.id.toString(),
      "id_proyecto": "1",
      "latitud": latitude.toString(),
      "longitud": longitude.toString(),
      "marca": selectedCarBrand,
      "tipo_vehiculo": selectedVehicleType,
      "multimedia": "multimedia/inspecciones/${widget.plateValue}",
    };
    for (var i = 0; i < photos.length; i++) {
      if (photos[i] != null) {
        http.MultipartFile multipartFile =
            await http.MultipartFile.fromPath("image-$i", photos[i]!.path);
        request.files.add(multipartFile);
      }
    }
    request.fields.addAll(data);
    http.StreamedResponse response = await request.send();
    final respStr = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final jsonResponse = respStr;
      final respuesta = jsonResponse.toString();

      if (respuesta.contains("0")) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(''),
            content: const Text(
              'Inspección registrada satisfactoriamente',
              style: TextStyle(fontSize: 25),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FindPlatePage(),
                  ),
                ),
                child: const Text(
                  'Aceptar',
                  style: TextStyle(fontSize: 25),
                ),
              ),
            ],
          ),
        );
      } else if (respuesta.contains("1")) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(''),
            content: const Text(
              'La placa ingresada ya cuenta con una inspección',
              style: TextStyle(fontSize: 25),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FindPlatePage(),
                  ),
                ),
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
          title: const Text(''),
          content: const Text(
            'Error de conexión con el servidor, favor informar al administrador',
            style: TextStyle(fontSize: 25),
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
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class FileInfo {
  final File file;
  final double sizeInKB;
  final String dimensions;

  FileInfo({
    required this.file,
    required this.sizeInKB,
    required this.dimensions,
  });
}

class ApiResponse {
  final int codigo;
  final String datos;

  ApiResponse({
    required this.codigo,
    required this.datos,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      codigo: json['CODIGO'] as int,
      datos: json['DATOS'] as String,
    );
  }
}
