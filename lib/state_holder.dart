import 'package:supabase_flutter/supabase_flutter.dart';
import 'models.dart';

class AppState {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal() {
    initDefaultData();
    initializeSupabase();
  }

  // Sales Advisor State
  String currentUserEmail = "giselle.benavides@gnb.com.pe"; // Kept variable name for compatibility
  String get advisorCode {
    if (currentUserEmail == "b8a8b13c-7033-4f9e-a1fb-26e1d2c67623") return "ID-Principal";
    return currentUserEmail.contains('@') ? currentUserEmail.split('@')[0].toUpperCase() : currentUserEmail.toUpperCase();
  }
  String get shortName {
    if (currentUserEmail == "b8a8b13c-7033-4f9e-a1fb-26e1d2c67623") return "Asesor Principal";
    return "Asesor " + (currentUserEmail.contains('@') 
      ? currentUserEmail.split('@')[0].split('.')[0].toUpperCase() 
      : currentUserEmail.toUpperCase());
  }

  // Database lists
  List<Client> assignedPortfolio = [];
  List<CreditApplication> creditApplications = [];
  List<ActivityLog> activities = [];

  // Sync variables
  DateTime lastSyncTime = DateTime.now().subtract(const Duration(hours: 2, minutes: 15));
  bool get hasPendingSync => creditApplications.any((app) => app.status == "Borrador" || app.status == "Pendiente");

  // Supabase Configuration Status
  bool useSupabase = false;

  // Performance indicators
  double get totalPlacedCredit => creditApplications
      .where((app) => app.status == "Transmitido" || app.status == "Aprobado" || app.status == "recibido_comite" || app.status == "desembolsado")
      .fold(0.0, (sum, app) => sum + app.amount);
  double get monthlyGoal => 250000.00;
  double get goalPercentage => (totalPlacedCredit / monthlyGoal).clamp(0.0, 1.0);

  void initializeSupabase() {
    try {
      // Check if Supabase client is initialized and active
      final _ = Supabase.instance.client;
      useSupabase = true;
      syncFromSupabase();
    } catch (_) {
      useSupabase = false;
    }
  }

  // ── LIVE SUPABASE SYNCHRONIZER ──
  Future<void> syncFromSupabase() async {
    if (!useSupabase) return;
    try {
      final client = Supabase.instance.client;
      
      // 1. Fetch assigned clients from 'clientes_cartera' (filter by asesor_id, which we store in currentUserEmail)
      final List<dynamic> portfolioResponse = await client
          .from('clientes_cartera')
          .select()
          .eq('asesor_id', currentUserEmail);

      if (portfolioResponse.isNotEmpty) {
        final List<Client> fetched = portfolioResponse
            .map((item) => Client.fromJson(item as Map<String, dynamic>))
            .toList();
        assignedPortfolio = fetched;
      }

      // 2. Fetch submitted credit applications from 'solicitudes_credito'
      final List<dynamic> applicationsResponse = await client
          .from('solicitudes_credito')
          .select()
          .eq('asesor_id', currentUserEmail)
          .order('fecha_transmision', ascending: false);

      if (applicationsResponse.isNotEmpty) {
        final List<CreditApplication> fetched = applicationsResponse
            .map((item) => CreditApplication.fromJson(item as Map<String, dynamic>))
            .toList();
        creditApplications = fetched;
        
        // Auto-agregar a la cartera los clientes que vienen de solicitudes asignadas
        for (final app in creditApplications) {
          if (!assignedPortfolio.any((c) => c.dni == app.clientDni)) {
            assignedPortfolio.add(Client(
              dni: app.clientDni,
              nombre: app.clientName,
              telefono: "Por actualizar", 
              direccion: "Registrado en Web", 
              sentinelRating: "Normal",
              sentinelScore: 700,
              deudaTotal: 0.0,
              isSync: true,
            ));
          }
        }
      }

      lastSyncTime = DateTime.now();
      
      addActivity(
        "Sincronización Exitosa",
        "Cartera y Solicitudes cargadas en tiempo real desde Supabase.",
      );
    } catch (e) {
      addActivity(
        "Error de Sincronización",
        "Conexión Supabase fallida: $e. Usando base de datos caché local.",
      );
    }
  }

  void initDefaultData() {
    // 1. Prepopulate Portfolio Cache (Offline Fallback)
    assignedPortfolio = [
      Client(
        dni: "47582910",
        nombre: "Carlos Mendoza Prado",
        telefono: "987349102",
        direccion: "Av. Larco 482, Miraflores, Lima",
        sentinelRating: "Normal",
        sentinelScore: 780,
        deudaTotal: 2450.00,
        isSync: true,
      ),
      Client(
        dni: "09284712",
        nombre: "Sofía Rojas Alva",
        telefono: "992847102",
        direccion: "Jr. Batalla de Junín 283, Surco, Lima",
        sentinelRating: "Normal",
        sentinelScore: 810,
        deudaTotal: 0.00,
        isSync: true,
      ),
      Client(
        dni: "28471920",
        nombre: "Juan Carlos Araujo",
        telefono: "940294820",
        direccion: "Av. Aviación 3920, San Borja, Lima",
        sentinelRating: "CPP", // Problemas Potenciales
        sentinelScore: 590,
        deudaTotal: 18450.00,
        isSync: true,
      ),
      Client(
        dni: "18492039",
        nombre: "Patricia Loli Ruiz",
        telefono: "930193840",
        direccion: "Jr. Huallaga 490, Cercado de Lima, Lima",
        sentinelRating: "Deficiente",
        sentinelScore: 420,
        deudaTotal: 32900.00,
        isSync: true,
      ),
    ];

    // 2. Prepopulate Credit Applications Cache (Offline Fallback)
    creditApplications = [
      CreditApplication(
        id: "SOL-99281",
        clientDni: "47582910",
        clientName: "Carlos Mendoza Prado",
        productType: "Consumo",
        amount: 25000.00,
        term: 24,
        income: 4200.00,
        documentPhotosCount: 3,
        status: "Transmitido",
        date: "2026-06-02 09:30",
      ),
      CreditApplication(
        id: "SOL-99081",
        clientDni: "28471920",
        clientName: "Juan Carlos Araujo",
        productType: "Consumo",
        amount: 15000.00,
        term: 12,
        income: 3100.00,
        documentPhotosCount: 2,
        status: "Borrador",
        date: "2026-06-02 10:10",
      ),
    ];

    // 3. Prepopulate Advisor Activity Logs
    activities = [
      ActivityLog(
        title: "Solicitud SOL-99281 Creada",
        description: "Captura de datos completa para Carlos Mendoza. Transmisión exitosa.",
        time: "Hoy, 09:30 AM",
      ),
      ActivityLog(
        title: "Borrador SOL-99081 Registrado",
        description: "Ingreso parcial de solicitud para Juan Araujo. Pendiente foto de DNI.",
        time: "Hoy, 10:10 AM",
      ),
      ActivityLog(
        title: "Sincronización de Cartera",
        description: "Base de datos local sincronizada con el servidor central GNB.",
        time: "Hoy, 08:15 AM",
      ),
    ];
  }

  Future<void> addApplication(CreditApplication app) async {
    creditApplications.insert(0, app);
    addActivity(
      "Solicitud ${app.id} Registrada",
      "Crédito ${app.productType} por S/ ${app.amount.toStringAsFixed(0)} en estado ${app.status}.",
    );

    // If live Supabase connection is active, upload immediately
    if (useSupabase && (app.status == "Transmitido" || app.status == "recibido_comite")) {
      try {
        final client = Supabase.instance.client;
        await client.from('solicitudes_credito').upsert({
          'solicitud_codigo': app.id,
          'asesor_id': currentUserEmail, // Usamos el UUID del estado
          'client_dni': app.clientDni,
          'client_nombre': app.clientName,
          'producto_tipo': app.productType,
          'monto_solicitado': app.amount,
          'plazo_meses': app.term,
          'ingreso_neto': app.income,
          'cuota_mensual': (app.amount * 1.14) / app.term,
          'estado': app.status,
          'fecha_transmision': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        addActivity("Error de Envío Supabase", "Guardado localmente como borrador offline: $e");
      }
    }
  }

  Future<void> transmitApplication(String id) async {
    final index = creditApplications.indexWhere((app) => app.id == id);
    if (index != -1) {
      final old = creditApplications[index];
      final dateStr = DateTime.now().toString().substring(0, 16);
      
      creditApplications[index] = CreditApplication(
        id: old.id,
        clientDni: old.clientDni,
        clientName: old.clientName,
        productType: old.productType,
        amount: old.amount,
        term: old.term,
        income: old.income,
        documentPhotosCount: old.documentPhotosCount,
        status: "recibido_comite", // Dashboard Web espera este estado
        date: dateStr,
      );
      
      addActivity(
        "Transmisión Exitosa ${old.id}",
        "Expediente digital de ${old.clientName} transmitido al departamento de Riesgos GNB.",
      );

      if (useSupabase) {
        try {
          final client = Supabase.instance.client;
          await client.from('solicitudes_credito').upsert({
            'solicitud_codigo': old.id,
            'asesor_id': currentUserEmail, // Usamos el UUID
            'client_dni': old.clientDni,
            'client_nombre': old.clientName,
            'producto_tipo': old.productType,
            'monto_solicitado': old.amount,
            'plazo_meses': old.term,
            'ingreso_neto': old.income,
            'cuota_mensual': (old.amount * 1.14) / old.term,
            'estado': "recibido_comite", // Estado esperado por el Web Core
            'fecha_transmision': DateTime.now().toIso8601String(),
          });
        } catch (_) {}
      }
    }
  }

  void addActivity(String title, String description) {
    activities.insert(
      0,
      ActivityLog(
        title: title,
        description: description,
        time: "Ahora mismo",
      ),
    );
  }

  Future<void> addNewClient(Client client) async {
    assignedPortfolio.insert(0, client);
    addActivity(
      "Cliente Nuevo Vinculado",
      "${client.nombre} (DNI ${client.dni}) agregado a tu cartera asignada de campo.",
    );

    if (useSupabase) {
      try {
        final clientClient = Supabase.instance.client;
        await clientClient.from('clientes_cartera').insert({
          'asesor_id': currentUserEmail, // UUID
          'dni': client.dni,
          'nombre': client.nombre,
          'telefono': client.telefono,
          'direccion': client.direccion,
          'sentinel_rating': client.sentinelRating,
          'sentinel_score': client.sentinelScore,
          'deuda_total_sbs': client.deudaTotal,
          'is_sync': true,
        });
      } catch (_) {}
    }
  }

  void resetState() {
    currentUserEmail = "giselle.benavides@gnb.com.pe";
    lastSyncTime = DateTime.now().subtract(const Duration(hours: 2, minutes: 15));
    initDefaultData();
    initializeSupabase();
  }
}
