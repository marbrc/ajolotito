import 'package:flutter/material.dart';

import '../dominio/categoria.dart';
import '../dominio/gestor_permiso.dart';
import 'ajolote_vm.dart';
import 'tema.dart';

/// El usuario manda: cada tipo de aviso se puede apagar por separado.
class PantallaAjustes extends StatelessWidget {
  const PantallaAjustes({super.key, required this.vm});
  final AjoloteViewModel vm;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        final concedido = vm.permiso == EstadoPermiso.concedido;
        return Scaffold(
          appBar: AppBar(title: const Text('Ajustes de avisos')),
          body: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 28), children: [
            Panel(
              color: concedido ? const Color(0xFFE3F0E6) : Naranja.durazno,
              borde: null,
              child: Row(children: [
                Icon(concedido ? Icons.check_circle_outline_rounded : Icons.block_rounded,
                    color: concedido ? Naranja.verde : Naranja.oscuro),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    switch (vm.permiso) {
                      EstadoPermiso.concedido => 'El sistema permite notificaciones',
                      EstadoPermiso.denegado => 'El sistema las tiene bloqueadas',
                      EstadoPermiso.sinPreguntar => 'Aún no has decidido',
                    },
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Naranja.texto),
                  ),
                ),
                TextButton(onPressed: vm.abrirAjustes, child: const Text('Ajustes del sistema')),
              ]),
            ),
            const SizedBox(height: 18),
            const Text('Tipos de aviso',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Naranja.texto)),
            const SizedBox(height: 4),
            const Text('Apaga solo los que no quieras recibir.', style: TextStyle(color: Naranja.suave)),
            const SizedBox(height: 10),
            Panel(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Column(children: [
                for (var i = 0; i < Categoria.values.length; i++) ...[
                  if (i > 0) const Divider(indent: 14, endIndent: 14),
                  SwitchListTile(
                    title: Text(Categoria.values[i].canal.nombre,
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Naranja.texto)),
                    subtitle: Text(Categoria.values[i].canal.descripcion),
                    value: vm.categorias[Categoria.values[i]] ?? true,
                    onChanged: (v) => vm.cambiarCategoria(Categoria.values[i], v),
                  ),
                ],
              ]),
            ),
            const SizedBox(height: 18),
            const Panel(
              color: Naranja.crema,
              borde: null,
              padding: EdgeInsets.all(16),
              child: Row(children: [
                Icon(Icons.bedtime_outlined, color: Naranja.oscuro),
                SizedBox(width: 12),
                Expanded(
                  child: Text('Silencio automático de 10 pm a 8 am. Máximo 3 avisos al día.',
                      style: TextStyle(color: Naranja.texto)),
                ),
              ]),
            ),
          ]),
        );
      },
    );
  }
}
