import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../dominio/gestor_permiso.dart';
import '../dominio/mascota.dart';
import 'ajolote_vm.dart';
import 'dibujo_ajolote.dart';
import 'pantalla_ajustes.dart';
import 'tema.dart';

class PantallaAjolote extends StatelessWidget {
  const PantallaAjolote({super.key, required this.vm});
  final AjoloteViewModel vm;

  String _textoHumor(Humor h) => switch (h) {
        Humor.feliz => 'Feliz y con la pancita llena',
        Humor.hambriento => 'Tiene hambre',
        Humor.famelico => '¡Está famélico!',
      };

  Color _colorHumor(Humor h) => switch (h) {
        Humor.feliz => Naranja.verde,
        Humor.hambriento => Naranja.principal,
        Humor.famelico => Naranja.rojo,
      };

  /// Pre-permiso: explica el VALOR antes de que salga el diálogo del sistema.
  Future<void> _activarAvisos(BuildContext context) async {
    final acepta = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        icon: const Icon(Icons.notifications_active_outlined, color: Naranja.principal, size: 32),
        title: const Text('¿Te avisamos cuando tenga hambre?'),
        content: const Text(
            'Solo te escribiremos cuando tu ajolote necesite comer, y una sorpresa por la tarde. '
            'Nada de madrugadas (silencio de 10 pm a 8 am) y puedes apagarlo cuando quieras.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Ahora no')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Sí, avísame')),
        ],
      ),
    );
    if (acepta != true) return; // no gastamos el permiso si el usuario dijo "ahora no"
    final r = await vm.activarAvisos();
    if (r == ResultadoPermiso.hayQueIrAAjustes && context.mounted) {
      final ir = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Los avisos están apagados'),
          content: const Text('Puedes activarlos en los ajustes del sistema.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Abrir ajustes')),
          ],
        ),
      );
      if (ir == true) await vm.abrirAjustes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        if (!vm.listo) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        final s = vm.saciedad;
        final humor = vm.humor;
        return Scaffold(
          appBar: AppBar(
            title: Text(vm.nombre.isEmpty ? 'Ajolotito' : vm.nombre),
            actions: [
              IconButton(
                tooltip: 'Ajustes de avisos',
                icon: const Icon(Icons.tune_rounded),
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute<void>(builder: (_) => PantallaAjustes(vm: vm))),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            children: [
              // ---------- El ajolote ----------
              Panel(
                color: Naranja.crema,
                borde: null,
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                child: Column(children: [
                  DibujoAjolote(humor: humor, tamano: 190),
                  const SizedBox(height: 6),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: _colorHumor(humor), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(_textoHumor(humor),
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Naranja.texto)),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: s / 100,
                      minHeight: 12,
                      backgroundColor: Colors.white,
                      color: _colorHumor(humor),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('Saciedad: ${s.toStringAsFixed(0)} / 100',
                      textAlign: TextAlign.center, style: const TextStyle(color: Naranja.suave, fontSize: 13)),
                ]),
              ),
              const SizedBox(height: 12),
              if (vm.aviso != null) ...[
                Panel(
                  color: Naranja.durazno,
                  borde: null,
                  padding: const EdgeInsets.all(14),
                  child: Text(vm.aviso!, style: const TextStyle(color: Naranja.texto)),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  style: vm.resaltarAlimentar ? FilledButton.styleFrom(backgroundColor: Naranja.oscuro) : null,
                  onPressed: vm.alimentar,
                  icon: const Icon(Icons.restaurant_rounded),
                  label: const Text('Dar de comer'),
                ),
              ),
              const SizedBox(height: 14),
              _TarjetaAvisos(vm: vm, alActivar: () => _activarAvisos(context)),
            ],
          ),
        );
      },
    );
  }
}

class _TarjetaAvisos extends StatelessWidget {
  const _TarjetaAvisos({required this.vm, required this.alActivar});
  final AjoloteViewModel vm;
  final VoidCallback alActivar;

  String _hora(DateTime t) =>
      '${t.day}/${t.month} · ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final activo = vm.permiso == EstadoPermiso.concedido;
    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('Avisos', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Naranja.texto)),
          const Spacer(),
          if (activo)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFE3F0E6), borderRadius: BorderRadius.circular(20)),
              child: const Text('Activados',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Naranja.verde)),
            ),
        ]),
        const SizedBox(height: 10),
        if (!activo)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: alActivar,
              icon: const Icon(Icons.notifications_active_outlined),
              label: Text(vm.permiso == EstadoPermiso.denegado
                  ? 'Avisos apagados · cómo activarlos'
                  : 'Avísame cuando tenga hambre'),
            ),
          )
        else ...[
          const Text('Próximos programados', style: TextStyle(color: Naranja.suave, fontSize: 13)),
          const SizedBox(height: 6),
          if (vm.programadas.isEmpty)
            const Text('Ninguno por ahora (se programan cuando sales de la app).',
                style: TextStyle(color: Naranja.texto))
          else
            for (final p in vm.programadas)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: Naranja.crema, borderRadius: BorderRadius.circular(8)),
                    child: Text(_hora(p.cuando),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Naranja.oscuro)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(p.titulo, style: const TextStyle(color: Naranja.texto))),
                ]),
              ),
          const SizedBox(height: 6),
          TextButton.icon(
            onPressed: vm.probarAhora,
            icon: const Icon(Icons.bolt_rounded),
            label: const Text('Probar una notificación ahora'),
          ),
        ],
        const Divider(height: 20),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Modo clase (1 hora = 1 minuto)', style: TextStyle(color: Naranja.texto)),
          subtitle: const Text('Para ver los avisos en minutos. Sal de la app para recibirlos.'),
          value: vm.modoClase,
          onChanged: vm.cambiarModoClase,
        ),
        if (kIsWeb)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              'Versión web: el navegador no permite avisos programados, así que aquí se muestran dentro '
              'de la app. En Android o iOS llegan como notificaciones de verdad.',
              style: TextStyle(fontSize: 12, color: Naranja.suave, height: 1.35),
            ),
          ),
      ]),
    );
  }
}
