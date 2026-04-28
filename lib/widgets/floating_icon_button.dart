import 'package:flutter/material.dart';

class FloatingIconButton extends StatelessWidget {
  final IconData icone;
  final bool modoEscuro;
  final VoidCallback aoClicar;

  const FloatingIconButton({
    super.key,
    required this.icone,
    required this.modoEscuro,
    required this.aoClicar,
  });

  @override
  Widget build(BuildContext context) {
    final corFundo = modoEscuro ? const Color(0xFF2A2A2A) : const Color(0xFFF4EFE6);
    final corSombra = modoEscuro ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.08);
    final corIcone = modoEscuro ? Colors.white70 : const Color(0xFF4A4A4A);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
              BoxShadow(
                color: corSombra,
                offset: const Offset(0, 2),
                blurRadius: 6,
              ),
            ],
      ),
      child: IconButton(
        icon: Icon(icone, color: corIcone),
        onPressed: aoClicar,
      ),
    );
  }
}
