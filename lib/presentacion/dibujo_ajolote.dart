import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../dominio/mascota.dart';

/// Un ajolote dibujado a mano con formas: cabeza durazno, branquias a los lados
/// y una carita que cambia con su humor (sin emojis).
class DibujoAjolote extends StatelessWidget {
  const DibujoAjolote({super.key, required this.humor, this.tamano = 200});
  final Humor humor;
  final double tamano;

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Ajolote',
        child: SizedBox(
          width: tamano,
          height: tamano * 0.8,
          child: CustomPaint(painter: _PintorAjolote(humor)),
        ),
      );
}

class _PintorAjolote extends CustomPainter {
  _PintorAjolote(this.humor);
  final Humor humor;

  static const _cuerpo = Color(0xFFFFC4A6);
  static const _branquia = Color(0xFFF08A5D);
  static const _mejilla = Color(0xFFF7A383);
  static const _tinta = Color(0xFF3A2418);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2 + size.height * 0.04);
    final r = size.height * 0.40;

    // Branquias: tres "plumitas" por lado.
    final pBranquia = Paint()
      ..color = _branquia
      ..strokeWidth = r * 0.17
      ..strokeCap = StrokeCap.round;
    const angulos = [-0.85, -0.4, 0.05]; // en abanico hacia arriba
    for (final lado in [-1.0, 1.0]) {
      for (var i = 0; i < angulos.length; i++) {
        final ang = angulos[i];
        final inicio = Offset(c.dx + lado * r * 0.82, c.dy - r * 0.42 + i * r * 0.26);
        final fin = Offset(
          inicio.dx + lado * r * 0.6 * math.cos(ang),
          inicio.dy + r * 0.6 * math.sin(ang),
        );
        canvas.drawLine(inicio, fin, pBranquia);
      }
    }

    // Cabeza (un óvalo ancho).
    canvas.drawOval(
      Rect.fromCenter(center: c, width: r * 2.15, height: r * 1.8),
      Paint()..color = _cuerpo,
    );

    // Mejillas.
    final pMejilla = Paint()..color = _mejilla.withValues(alpha: 0.55);
    canvas.drawOval(Rect.fromCenter(center: c + Offset(-r * 0.62, r * 0.22), width: r * 0.36, height: r * 0.2), pMejilla);
    canvas.drawOval(Rect.fromCenter(center: c + Offset(r * 0.62, r * 0.22), width: r * 0.36, height: r * 0.2), pMejilla);

    // Ojos.
    final pTinta = Paint()..color = _tinta;
    final ojoIzq = c + Offset(-r * 0.42, -r * 0.1);
    final ojoDer = c + Offset(r * 0.42, -r * 0.1);
    canvas.drawCircle(ojoIzq, r * 0.1, pTinta);
    canvas.drawCircle(ojoDer, r * 0.1, pTinta);
    final pBrillo = Paint()..color = Colors.white;
    canvas.drawCircle(ojoIzq + Offset(r * 0.03, -r * 0.03), r * 0.03, pBrillo);
    canvas.drawCircle(ojoDer + Offset(r * 0.03, -r * 0.03), r * 0.03, pBrillo);

    // Boca según el humor.
    final pBoca = Paint()
      ..color = _tinta
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.06
      ..strokeCap = StrokeCap.round;
    final boca = c + Offset(0, r * 0.25);
    switch (humor) {
      case Humor.feliz:
        // Sonrisa amplia.
        canvas.drawArc(Rect.fromCenter(center: boca, width: r * 0.6, height: r * 0.36), 0.15, math.pi - 0.3, false, pBoca);
      case Humor.hambriento:
        // Boquita abierta pidiendo comida.
        canvas.drawOval(Rect.fromCenter(center: boca + Offset(0, r * 0.05), width: r * 0.22, height: r * 0.26), pBoca);
      case Humor.famelico:
        // Boca triste y una lagrimita.
        canvas.drawArc(Rect.fromCenter(center: boca + Offset(0, r * 0.18), width: r * 0.5, height: r * 0.3), math.pi + 0.2, math.pi - 0.4, false, pBoca);
        final lagrima = Path()
          ..moveTo(ojoDer.dx + r * 0.05, ojoDer.dy + r * 0.12)
          ..quadraticBezierTo(ojoDer.dx + r * 0.18, ojoDer.dy + r * 0.32, ojoDer.dx + r * 0.05, ojoDer.dy + r * 0.36)
          ..quadraticBezierTo(ojoDer.dx - r * 0.08, ojoDer.dy + r * 0.32, ojoDer.dx + r * 0.05, ojoDer.dy + r * 0.12);
        canvas.drawPath(lagrima, Paint()..color = const Color(0xFF7FB3D5));
    }
  }

  @override
  bool shouldRepaint(_PintorAjolote old) => old.humor != humor;
}
