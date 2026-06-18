import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../models.dart';
import '../state_holder.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final AppState state = AppState();
  final _dniController = TextEditingController(text: "10294857"); // Default prefilled
  
  bool _isLoading = false;
  Client? _queriedClient;
  bool _hasQueried = false;

  void _handleQuery() {
    final dni = _dniController.text.trim();
    if (dni.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("El DNI debe tener estrictamente 8 dígitos"),
          backgroundColor: GnbColors.rojoError,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _hasQueried = false;
      _queriedClient = null;
    });

    // Simulate real-time credit score decryption
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      // Check if client exists in portfolio
      final index = state.assignedPortfolio.indexWhere((c) => c.dni == dni);
      Client client;

      if (index != -1) {
        client = state.assignedPortfolio[index];
      } else {
        // Generate a random high-fidelity client if not exists
        final randomScores = [320, 510, 780, 890];
        final randomRatings = ["Pérdida", "CPP", "Normal", "Normal"];
        final idx = dni.hashCode % 4;
        
        client = Client(
          dni: dni,
          nombre: "Sujeto de Consulta DNI $dni",
          telefono: "9" + (10000000 + (dni.hashCode % 89999999)).toString(),
          direccion: "Dirección Registrada de Campo, Lima",
          sentinelRating: randomRatings[idx],
          sentinelScore: randomScores[idx],
          deudaTotal: (dni.hashCode % 20) * 4500.0,
          isSync: true,
        );
      }

      setState(() {
        _isLoading = false;
        _queriedClient = client;
        _hasQueried = true;
      });

      state.addActivity(
        "Consulta Sentinel DNI $dni",
        "Score obtenido: ${client.sentinelScore} Pts (${client.sentinelRating}).",
      );
    });
  }

  Color _getRatingColor(String rating) {
    switch (rating) {
      case "Normal":
        return GnbColors.verdeExito;
      case "CPP":
        return GnbColors.naranjaGNB;
      case "Deficiente":
        return Colors.orange[800]!;
      case "Pérdida":
        return GnbColors.rojoError;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Query Card ──
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: GnbColors.bordeSuave),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.01),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Consulta en Campo Sentinel SBS",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: GnbColors.verdeBosqueOscuro,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Ingrese el DNI del cliente para verificar su score crediticio Infocorp y deudas vigentes en el sistema financiero.",
                  style: TextStyle(fontSize: 11, color: GnbColors.grisSage),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _dniController,
                        keyboardType: TextInputType.number,
                        maxLength: 8,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: GnbColors.verdeBosqueOscuro,
                        ),
                        decoration: const InputDecoration(
                          labelText: "DNI de Cliente",
                          counterText: "",
                          prefixIcon: Icon(Icons.badge_outlined, color: GnbColors.verdeBotonForest),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleQuery, // Corrected from _handleLogin to _handleQuery
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          backgroundColor: GnbColors.azulGNB,
                        ),
                        child: InkWell(
                          onTap: _isLoading ? null : _handleQuery,
                          child: const Icon(Icons.search_rounded, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Query Loading State ──
          if (_isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Column(
                  children: const [
                    CircularProgressIndicator(color: GnbColors.azulGNB),
                    SizedBox(height: 16),
                    Text(
                      "Consultando base de datos Sentinel Infocorp...",
                      style: TextStyle(fontSize: 12, color: GnbColors.grisSage, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Cifrado SBS seguro habilitado.",
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

          // ── Score Results ──
          if (_hasQueried && _queriedClient != null) ...[
            Center(
              child: Column(
                children: [
                  // Client Header Badge
                  Text(
                    _queriedClient!.nombre,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: GnbColors.verdeBosqueOscuro,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "DNI ${_queriedClient!.dni}",
                    style: const TextStyle(fontSize: 12, color: GnbColors.grisSage, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // ── Majestic Score Speedometer Dial ──
                  SizedBox(
                    width: 220,
                    height: 130,
                    child: CustomPaint(
                      painter: ScoreGaugePainter(score: _queriedClient!.sentinelScore),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Score text
                  Text(
                    "${_queriedClient!.sentinelScore}",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: _getRatingColor(_queriedClient!.sentinelRating),
                      height: 1.0,
                    ),
                  ),
                  Text(
                    "Puntos Sentinel (SBS)",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getRatingColor(_queriedClient!.sentinelRating).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _getRatingColor(_queriedClient!.sentinelRating).withOpacity(0.4)),
                    ),
                    child: Text(
                      "CLASIFICACIÓN: ${_queriedClient!.sentinelRating.toUpperCase()}",
                      style: TextStyle(
                        color: _getRatingColor(_queriedClient!.sentinelRating),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Financial Profile Details ──
            const Padding(
              padding: EdgeInsets.only(left: 4.0, bottom: 12),
              child: Text(
                "Resumen de Deuda Vigente",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: GnbColors.verdeBosqueOscuro),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: GnbColors.bordeSuave),
              ),
              child: Column(
                children: [
                  _buildFinancialRow("Deuda SBS", "S/ ${_queriedClient!.deudaTotal.toStringAsFixed(2)}"),
                  const Divider(color: GnbColors.bordeSuave),
                  _buildFinancialRow("Tarjetas Activas", _queriedClient!.sentinelScore > 500 ? "3 Entidades" : "1 Entidad"),
                  const Divider(color: GnbColors.bordeSuave),
                  _buildFinancialRow("Calificación en SBS", _queriedClient!.sentinelRating),
                  const Divider(color: GnbColors.bordeSuave),
                  _buildFinancialRow(
                    "Dictamen de Riesgo", 
                    _queriedClient!.sentinelScore >= 600 ? "APTO PARA CRÉDITO" : "RECHAZAR SOLICITUD",
                    valueColor: _queriedClient!.sentinelScore >= 600 ? GnbColors.verdeExito : GnbColors.rojoError,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Start Application Shortcut from Score Checker
            if (_queriedClient!.sentinelScore >= 500)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Redirect to index 4 prefilled
                    final scaffold = context.findAncestorStateOfType<State<StatefulWidget>>();
                    if (scaffold != null && scaffold.toString().contains('AppScaffoldState')) {
                      (scaffold as dynamic).setState(() {
                        (scaffold as dynamic)._currentIndex = 4; // Loan capture
                      });
                    }
                  },
                  icon: const Icon(Icons.add_box_rounded, color: Colors.white),
                  style: ElevatedButton.styleFrom(backgroundColor: GnbColors.verdeBotonForest),
                  label: const Text("VINCULAR A SOLICITUD DE CRÉDITO", style: TextStyle(color: Colors.white)),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildFinancialRow(String title, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: GnbColors.grisSage),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: valueColor ?? GnbColors.verdeBosqueOscuro,
            ),
          ),
        ],
      ),
    );
  }
}

// ── CUSTOM PAINTER FOR PREMIUM SCORE SPEEDOMETER DIAL ──
class ScoreGaugePainter extends CustomPainter {
  final int score;

  ScoreGaugePainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    // 1. Draw Speedometer Arc
    final rect = Rect.fromCircle(center: center, radius: radius - 15);
    final Paint arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    // Red Sector (Score 0 to 450)
    arcPaint.color = GnbColors.rojoError;
    canvas.drawArc(rect, math.pi, math.pi * 0.45, false, arcPaint);

    // Orange/Yellow Sector (Score 450 to 700)
    arcPaint.color = GnbColors.naranjaGNB;
    canvas.drawArc(rect, math.pi * 1.45, math.pi * 0.25, false, arcPaint);

    // Green Sector (Score 700 to 1000)
    arcPaint.color = GnbColors.verdeExito;
    canvas.drawArc(rect, math.pi * 1.70, math.pi * 0.30, false, arcPaint);

    // 2. Calculate Pointer Angle
    // Score range 0 to 1000 maps to Pi to 2*Pi
    final double percentage = (score / 1000).clamp(0.0, 1.0);
    final double angle = math.pi + (percentage * math.pi);

    // 3. Draw Pointer Needle
    final Paint needlePaint = Paint()
      ..color = GnbColors.verdeBosqueOscuro
      ..style = PaintingStyle.fill;

    // Draw central circular cap
    canvas.drawCircle(center, 10, needlePaint);
    canvas.drawCircle(center, 4, Paint()..color = Colors.white);

    // Calculate pointer tip coordinates
    final pointerLen = radius - 28;
    final tipX = center.dx + pointerLen * math.cos(angle);
    final tipY = center.dy + pointerLen * math.sin(angle);

    // Draw beautiful arrow pointer lines
    final Path needlePath = Path();
    final double perpAngle1 = angle + math.pi / 2;
    final double perpAngle2 = angle - math.pi / 2;
    
    // Triangle needle
    needlePath.moveTo(center.dx + 6 * math.cos(perpAngle1), center.dy + 6 * math.sin(perpAngle1));
    needlePath.lineTo(tipX, tipY);
    needlePath.lineTo(center.dx + 6 * math.cos(perpAngle2), center.dy + 6 * math.sin(perpAngle2));
    needlePath.close();

    canvas.drawPath(needlePath, needlePaint);
  }

  @override
  bool shouldRepaint(covariant ScoreGaugePainter oldDelegate) {
    return oldDelegate.score != score;
  }
}
