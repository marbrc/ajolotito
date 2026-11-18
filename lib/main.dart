import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'dominio/gestor_permiso.dart';
import 'dominio/puerto.dart';
import 'dominio/reloj.dart';
import 'dominio/servicio.dart';
import 'infra/almacen_prefs.dart';
import 'infra/puerto_real.dart';
import 'infra/puerto_web.dart';
import 'presentacion/ajolote_vm.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  // En el teléfono usamos el plugin real. En la web (navegador) no existen las notificaciones
  // programadas, así que usamos un adaptador que las simula dentro de la app.
  final PuertoNotificaciones puerto = kIsWeb ? PuertoWeb(prefs) : PuertoReal();
  await puerto.inicializar();
  final almacen = AlmacenPrefs(prefs);
  const reloj = RelojSistema();

  final servicio = ServicioAjolote(puerto: puerto, almacen: almacen, reloj: reloj);
  final gestor = GestorPermiso(puerto: puerto, almacen: almacen);
  final vm = AjoloteViewModel(servicio: servicio, gestor: gestor, reloj: reloj);

  puerto.escucharToques(vm.alTocarNotificacion);
  if (puerto is PuertoWeb) {
    puerto.alMostrar = (titulo, cuerpo, payload) =>
        mostrarAvisoDentroDeLaApp(titulo, cuerpo, alTocar: () => puerto.tocar(payload));
  }
  final destino = await servicio.destinoDeLanzamiento();

  runApp(AppAjolote(vm: vm, destinoInicial: destino));
}
