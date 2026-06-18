class Client {
  final String dni;
  final String nombre;
  final String telefono;
  final String direccion;
  final String sentinelRating; // "Normal", "CPP" (Problemas Potenciales), "Deficiente", "Pérdida"
  final int sentinelScore; // 0 to 1000 (Infocorp scoring)
  final double deudaTotal;
  bool isSync;

  Client({
    required this.dni,
    required this.nombre,
    required this.telefono,
    required this.direccion,
    required this.sentinelRating,
    required this.sentinelScore,
    required this.deudaTotal,
    this.isSync = true,
  });

  Map<String, dynamic> toJson() => {
    'dni': dni,
    'nombre': nombre,
    'telefono': telefono,
    'direccion': direccion,
    'sentinel_rating': sentinelRating,
    'sentinel_score': sentinelScore,
    'deuda_total_sbs': deudaTotal,
    'is_sync': isSync,
  };

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      dni: (json['dni'] ?? '') as String,
      nombre: (json['nombre'] ?? '') as String,
      telefono: (json['telefono'] ?? '') as String,
      direccion: (json['direccion'] ?? '') as String,
      sentinelRating: (json['sentinel_rating'] ?? json['sentinelRating'] ?? 'Normal') as String,
      sentinelScore: (json['sentinel_score'] ?? json['sentinelScore'] ?? 700) as int,
      deudaTotal: ((json['deuda_total_sbs'] ?? json['deudaTotal'] ?? 0.0) as num).toDouble(),
      isSync: (json['is_sync'] ?? json['isSync'] ?? true) as bool,
    );
  }
}

class CreditApplication {
  final String id;
  final String clientDni;
  final String clientName;
  final String productType; // "Consumo", "Microempresa", "Hipotecario"
  final double amount;
  final int term;
  final double income;
  int documentPhotosCount;
  String status; // "Borrador", "Pendiente", "Transmitido"
  final String date;

  CreditApplication({
    required this.id,
    required this.clientDni,
    required this.clientName,
    required this.productType,
    required this.amount,
    required this.term,
    required this.income,
    this.documentPhotosCount = 0,
    required this.status,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'solicitud_codigo': id,
    'client_dni': clientDni,
    'client_nombre': clientName,
    'producto_tipo': productType,
    'monto_solicitado': amount,
    'plazo_meses': term,
    'ingreso_neto': income,
    'documentPhotosCount': documentPhotosCount,
    'estado': status,
    'fecha_transmision': date,
  };

  factory CreditApplication.fromJson(Map<String, dynamic> json) {
    return CreditApplication(
      id: (json['solicitud_codigo'] ?? json['id'] ?? '') as String,
      clientDni: (json['client_dni'] ?? json['clientDni'] ?? '') as String,
      clientName: (json['client_nombre'] ?? json['clientName'] ?? '') as String,
      productType: (json['producto_tipo'] ?? json['productType'] ?? '') as String,
      amount: ((json['monto_solicitado'] ?? json['amount'] ?? 0.0) as num).toDouble(),
      term: (json['plazo_meses'] ?? json['term'] ?? 0) as int,
      income: ((json['ingreso_neto'] ?? json['income'] ?? 0.0) as num).toDouble(),
      documentPhotosCount: json['documentPhotosCount'] as int? ?? 
          ((json['url_foto_dni'] != null ? 1 : 0) + 
           (json['url_foto_recibo'] != null ? 1 : 0) + 
           (json['url_foto_ingresos'] != null ? 1 : 0)),
      status: (json['estado'] ?? json['status'] ?? 'Borrador') as String,
      date: (json['fecha_transmision'] ?? json['date'] ?? '') as String,
    );
  }
}

class ActivityLog {
  final String title;
  final String description;
  final String time;

  ActivityLog({
    required this.title,
    required this.description,
    required this.time,
  });
}
