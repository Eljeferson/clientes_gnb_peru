import 'package:supabase/supabase.dart';

void main() async {
  final client = SupabaseClient(
    'https://mgrzsajmbavdhltupzmu.supabase.co',
    'sb_publishable_Un5zA-C3VSJ5n4QQp9VyOA_j2n_eomd',
  );

  try {
    print("Testing insert into solicitudes_credito...");
    await client.from('solicitudes_credito').insert({
      'solicitud_codigo': 'TEST-12345',
      'asesor_id': null,
      'client_dni': '12345678',
      'client_nombre': 'TEST NAME',
      'producto_tipo': 'Consumo',
      'monto_solicitado': 1000.0,
      'plazo_meses': 12,
      'ingreso_neto': 2000.0,
      'cuota_mensual': 100.0,
      'estado': 'Transmitido',
      'fecha_transmision': DateTime.now().toIso8601String(),
    });
    print("Insert success!");
    
    final response = await client.from('solicitudes_credito').select().eq('solicitud_codigo', 'TEST-12345');
    print("Select success: $response");
  } catch (e) {
    print("Error during insert: $e");
  }
}
