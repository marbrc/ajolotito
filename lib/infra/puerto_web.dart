import 'package:shared_preferences/shared_preferences.dart';

import '../dominio/categoria.dart';
import '../dominio/planificador.dart';
import '../dominio/puerto.dart';

/// Adaptador para la versión WEB.
///
/// Los navegadores no permiten notificaciones PROGRAMADAS (ni repetidas), así que en la web
/// no se puede avisar "dentro de 6 horas". Para que la app se pueda demostrar desde el
/// navegador del celular, este adaptador:
///  - guarda la agenda en memoria (se ve en la pantalla, igual que en el teléfono),
///  - muestra las notificaciones inmediatas DENTRO de la app (con [alMostrar]),
///  - simula el permiso y lo recuerda entre recargas.
/// Gracias al patrón de puerto, el resto de la app no se entera de nada de esto.
class PuertoWeb implements PuertoNotificaciones {
  PuertoWeb(this._prefs);
  final SharedPreferences _prefs;
  static const _kActivas = 'web_avisos_activos';

  final Map<int, PlanNotificacion> programadas = {};
  void Function(String? payload)? _alTocar;

  /// La app conecta aquí cómo pintar un aviso dentro de la pantalla.
  void Function(String titulo, String cuerpo, String payload)? alMostrar;

  @override
  Future<void> inicializar() async {}

  @override
  Future<bool> notificacionesActivas() async => _prefs.getBool(_kActivas) ?? false;

  @override
  Future<bool> pedirPermiso() async {
    await _prefs.setBool(_kActivas, true);
    return true;
  }

  @override
  Future<void> programar(PlanNotificacion plan) async => programadas[plan.id] = plan;

  @override
  Future<void> mostrarAhora({
    required int id,
    required String titulo,
    required String cuerpo,
    required Categoria categoria,
    required String payload,
  }) async =>
      alMostrar?.call(titulo, cuerpo, payload);

  @override
  Future<void> cancelar(int id) async => programadas.remove(id);

  @override
  Future<String?> payloadDeLanzamiento() async => null;

  @override
  void escucharToques(void Function(String? payload) alTocar) => _alTocar = alTocar;

  /// Simula que el usuario tocó el aviso que se mostró dentro de la app.
  void tocar(String? payload) => _alTocar?.call(payload);

  /// En la web no hay "ajustes del sistema" de la app: volver a activar es reiniciar la marca.
  @override
  Future<void> abrirAjustes() async => _prefs.setBool(_kActivas, true);
}
