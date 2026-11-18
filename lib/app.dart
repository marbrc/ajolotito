import 'package:flutter/material.dart';

import 'dominio/payload.dart';
import 'presentacion/ajolote_vm.dart';
import 'presentacion/pantalla_ajolote.dart';
import 'presentacion/tema.dart';

/// Llave global para poder mostrar avisos dentro de la app desde fuera de un widget
/// (la usa la versión web para simular las notificaciones).
final GlobalKey<ScaffoldMessengerState> mensajero = GlobalKey<ScaffoldMessengerState>();

/// Muestra un aviso estilo notificación DENTRO de la app (solo se usa en la web).
void mostrarAvisoDentroDeLaApp(String titulo, String cuerpo, {required VoidCallback alTocar}) {
  mensajero.currentState
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      duration: const Duration(seconds: 6),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(titulo, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 2),
        Text(cuerpo, style: const TextStyle(color: Color(0xFFF6DCCB))),
      ]),
      action: SnackBarAction(label: 'Abrir', textColor: Naranja.durazno, onPressed: alTocar),
    ));
}

class AppAjolote extends StatefulWidget {
  const AppAjolote({super.key, required this.vm, this.destinoInicial = Destino.inicio});
  final AjoloteViewModel vm;
  final Destino destinoInicial;

  @override
  State<AppAjolote> createState() => _AppAjoloteState();
}

class _AppAjoloteState extends State<AppAjolote> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.vm.iniciar(destino: widget.destinoInicial);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) => widget.vm.alCambiarCicloDeVida(state);

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Ajolotito',
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: mensajero,
        theme: TemaNaranja.claro,
        // En la compu no se estira de lado a lado: se centra con ancho de teléfono.
        builder: (context, child) => ColoredBox(
          color: Naranja.fondo,
          child: Center(
            child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 520), child: child),
          ),
        ),
        home: PantallaAjolote(vm: widget.vm),
      );
}
