class LocalInspection {
  final String plate;
  final String fecha_inspeccion;
  final String fecha_ingreso;
  final String estado;
  final String id_funcionario;
  final String id_proyecto;
  final String latitud;
  final String longitud;
  final String marca;
  final String tipo_vehiculo;
  final String multimedia;
  final String numero_motor;
  final String numero_chasis;
   int local_state;


  LocalInspection({
    required this.plate,
    required this.fecha_inspeccion,
    required this.fecha_ingreso,
    required this.estado,
    required this.id_funcionario,
    required this.id_proyecto,
    required this.latitud,
    required this.longitud,
    required this.marca,
    required this.tipo_vehiculo,
    required this.multimedia,
    required this.numero_motor,
    required this.numero_chasis,
    required this.local_state,
  });

  factory LocalInspection.fromJson(Map<String, dynamic> json) {
  return LocalInspection(
    plate: json['plate'] as String,
    fecha_inspeccion: json['fecha_inspeccion'] as String,
    fecha_ingreso: json['fecha_ingreso'] as String,
    estado: json['estado'] as String,
    id_funcionario: json['id_funcionario'] as String,
    id_proyecto: json['id_proyecto'] as String,
    latitud: json['latitud'] as String,
    longitud: json['longitud'] as String,
    marca: json['marca'] as String,
    tipo_vehiculo: json['tipo_vehiculo'] as String,
    multimedia: json['multimedia'] as String,
    numero_motor: json['numero_motor'] as String,
    numero_chasis: json['numero_chasis'] as String,
    local_state: json['local_state'] as int,
  );
}


 // Método toJson para convertir la instancia a un mapa
  Map<String, dynamic> toJson() {
    return {
      'plate': plate,
      'fecha_inspeccion': fecha_inspeccion,
      'fecha_ingreso':fecha_ingreso,
      'estado':estado,
      'id_funcionario':id_funcionario,
      'id_proyecto':id_proyecto,
      'latitud':latitud,
      'longitud':longitud,
      'marca':marca,
      'tipo_vehiculo':tipo_vehiculo,
      'multimedia':multimedia,
      'numero_motor':numero_motor,
      'numero_chasis':numero_chasis,
      'local_state':local_state
    };
  }
}


  