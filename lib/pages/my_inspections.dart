import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';

void main() {
  runApp(MyInspectionsPage());
}

class Inspeccion {
  final int id;
  final String fechaInspeccion;
  final String latitud;
  final String longitud;
  final String fechaIngreso;
  final String estado;
  final int idFuncionario;
  final int idProyecto;
  final String placa;
  final String multimedia;
  final String modelo;
  final String numeroChasis;
  final String numeroMotor;
  final String marca;
  final String tipoServicio;
  final String tipoVehiculo;
  final String organismoTransito;
  final int idPropietario;
  final String nombrePropietario;

  Inspeccion({
    required this.id,
    required this.fechaInspeccion,
    required this.latitud,
    required this.longitud,
    required this.fechaIngreso,
    required this.estado,
    required this.idFuncionario,
    required this.idProyecto,
    required this.placa,
    required this.multimedia,
    required this.modelo,
    required this.numeroChasis,
    required this.numeroMotor,
    required this.marca,
    required this.tipoServicio,
    required this.tipoVehiculo,
    required this.organismoTransito,
    required this.idPropietario,
    required this.nombrePropietario,
  });

  factory Inspeccion.fromJson(Map<String, dynamic> json) {
    return Inspeccion(
      id: json['id_inspeccion'] ?? 0,
      fechaInspeccion: json['fecha_inspeccion'] ?? '',
      latitud: json['latitud'] ?? '',
      longitud: json['longitud'] ?? '',
      fechaIngreso: json['fecha_ingreso'] ?? '',
      estado: json['estado'] ?? '',
      idFuncionario: json['id_funcionario'] ?? 0,
      idProyecto: json['id_proyecto'] ?? 0,
      placa: json['placa'] ?? '',
      multimedia: json['multimedia'] ?? '',
      modelo: json['v.modelo'] ?? '',
      numeroChasis: json['numero_chasis'] ?? '',
      numeroMotor: json['numero_motor'] ?? '',
      marca: json['marca'] ?? '',
      tipoServicio: json['tipo_servicio'] ?? '',
      tipoVehiculo: json['tipo_vehiculo'] ?? '',
      organismoTransito: json['organismo_transito'] ?? '',
      idPropietario: json['id_propietario'] ?? 0,
      nombrePropietario: json['nombre_propietario'] ?? '',
    );
  }
}

class MyInspectionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Inspecciones',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Inspeccion> inspecciones = [];

  @override
  void initState() {
    super.initState();
    _loadInspections();
  }

  Future<void> _loadInspections() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/tus_datos.json';

    try {
      final File file = File(filePath);
      final String fileContent = await file.readAsString();
      final List<dynamic> responseData = jsonDecode(fileContent);

      List<Inspeccion> fetchedInspections = responseData
          .map((inspeccionData) => Inspeccion.fromJson(inspeccionData))
          .toList();

      setState(() {
        inspecciones = fetchedInspections;
      });
    } catch (error) {
      print('Error reading file: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _getUniqueDates().length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Lista de Inspecciones'),
          bottom: TabBar(
  tabs: _getUniqueDates().map((date) {
    int inspectionsCount = _getInspectionsCountByDate(date);
    return Tab(
      child: RichText(
        text: TextSpan(
          text: '$date ',
          style: TextStyle(
            fontWeight: FontWeight.bold, // Estilo de texto en negrita solo para la fecha
          ),
          children: [
            TextSpan(
              text: '($inspectionsCount)',
              style: TextStyle(fontWeight: FontWeight.normal), // Estilo normal para el contador
            ),
          ],
        ),
      ),
    );
  }).toList(),
),
        ),
        body: TabBarView(
          children: _getUniqueDates().map((date) {
            return _buildInspectionListByDate(date);
          }).toList(),
        ),
      ),
    );
  }

  int _getInspectionsCountByDate(String date) {
    return inspecciones.where((inspeccion) => inspeccion.fechaInspeccion == date).length;
  }

  Widget _buildInspectionListByDate(String date) {
    List<Inspeccion> inspectionsByDate = inspecciones
        .where((inspeccion) => inspeccion.fechaInspeccion == date)
        .toList();

    return ListView.builder(
      itemCount: inspectionsByDate.length,
      itemBuilder: (context, index) {
        return _buildInspeccionCard(inspectionsByDate[index]);
      },
    );
  }

  List<String> _getUniqueDates() {
    return inspecciones.map((inspeccion) => inspeccion.fechaInspeccion).toSet().toList();
  }

  Widget _buildInspeccionCard(Inspeccion inspeccion) {
    IconData iconData;
    Color iconColor;

    if (inspeccion.estado == '1') {
      // Estado 1: Aprobada (Icono verde)
      iconData = Icons.check;
      iconColor = Colors.green;
    } else {
      // Otro estado: Rechazada (Icono rojo)
      iconData = Icons.close;
      iconColor = Colors.red;
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text('Placa: ${inspeccion.placa}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo de Vehículo: ${inspeccion.tipoVehiculo}'),
            Text('Fecha: ${inspeccion.fechaInspeccion}'),
            Row(
              children: [
                Icon(iconData, color: iconColor),
                SizedBox(width: 8),
                Text('Estado: ${inspeccion.estado == '1' ? 'Aprobada' : 'Rechazada'}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
