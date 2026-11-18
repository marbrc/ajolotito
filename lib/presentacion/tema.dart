import 'package:flutter/material.dart';

/// Paleta naranja: del durazno pastel al mandarina intenso (sin llegar a fosforescente).
class Naranja {
  static const principal = Color(0xFFE8743B); // mandarina
  static const oscuro = Color(0xFFB9531F); // para textos fuertes y resaltar
  static const durazno = Color(0xFFFFE1CC); // pastel para fondos de tarjetas
  static const crema = Color(0xFFFFF1E6); // pastel más claro
  static const fondo = Color(0xFFFFF8F2);
  static const texto = Color(0xFF3A2418);
  static const suave = Color(0xFF9A7563);
  static const borde = Color(0xFFF2DCCB);
  static const verde = Color(0xFF4E8A5E);
  static const rojo = Color(0xFFC24A3A);
}

class TemaNaranja {
  static ThemeData get claro {
    const esquema = ColorScheme(
      brightness: Brightness.light,
      primary: Naranja.principal,
      onPrimary: Colors.white,
      primaryContainer: Naranja.durazno,
      onPrimaryContainer: Naranja.texto,
      secondary: Naranja.oscuro,
      onSecondary: Colors.white,
      secondaryContainer: Naranja.crema,
      onSecondaryContainer: Naranja.texto,
      error: Naranja.rojo,
      onError: Colors.white,
      errorContainer: Color(0xFFF8DCD6),
      onErrorContainer: Color(0xFF5E1D14),
      surface: Colors.white,
      onSurface: Naranja.texto,
      onSurfaceVariant: Naranja.suave,
      outline: Naranja.borde,
    );

    final redondo = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: Naranja.fondo,
      appBarTheme: const AppBarTheme(
        backgroundColor: Naranja.fondo,
        foregroundColor: Naranja.texto,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Naranja.texto,
          fontSize: 21,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: Naranja.principal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: redondo,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Naranja.oscuro,
          backgroundColor: Colors.white,
          side: const BorderSide(color: Naranja.borde),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: redondo,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: Naranja.oscuro),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? Colors.white : Naranja.suave),
        trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? Naranja.principal : Naranja.crema),
        trackOutlineColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? Naranja.principal : Naranja.borde),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Naranja.principal,
        linearTrackColor: Naranja.crema,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        titleTextStyle: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: Naranja.texto),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Naranja.texto,
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(color: Naranja.borde, space: 1),
    );
  }
}

/// Contenedor con borde fino: la tarjeta base de la app.
class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.padding = const EdgeInsets.all(18),
    this.borde = Naranja.borde,
  });
  final Widget child;
  final Color color;
  final EdgeInsets padding;
  final Color? borde;

  // Es un Material (y no un Container con color) para que los interruptores y botones de
  // adentro (SwitchListTile, ListTile) puedan pintar su efecto al tocarlos.
  @override
  Widget build(BuildContext context) => Material(
        color: color,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: borde == null ? BorderSide.none : BorderSide(color: borde!),
        ),
        child: Padding(
          padding: padding,
          child: SizedBox(width: double.infinity, child: child),
        ),
      );
}
