import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String rotulo;
  final String dica;
  final bool senha;
  final TextEditingController controlador;
  final bool modoEscuro;

  const CustomTextField({
    super.key,
    required this.rotulo,
    required this.dica,
    required this.senha,
    required this.controlador,
    required this.modoEscuro,
  });

  @override
  Widget build(BuildContext context) {
    final corRotulo = modoEscuro ? const Color(0xFFCCCCCC) : const Color(0xFF4A4A4A);
    final corFundo = modoEscuro ? const Color(0xFF252525) : const Color(0xFFEBE4D5);
    final corSombraClara = modoEscuro ? Colors.white.withOpacity(0.03) : Colors.white.withOpacity(0.6);
    final corSombraEscura = modoEscuro ? Colors.black.withOpacity(0.6) : Colors.black.withOpacity(0.03);
    final corTexto = modoEscuro ? Colors.white : Colors.black87;
    final corDica = modoEscuro ? Colors.grey[600] : const Color(0xFF9E9E9E);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          rotulo.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: corRotulo,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: corFundo,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: corSombraClara,
                offset: const Offset(-2, -2),
                blurRadius: 4,
              ),
              BoxShadow(
                color: corSombraEscura,
                offset: const Offset(2, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: TextField(
            controller: controlador,
            obscureText: senha,
            style: TextStyle(color: corTexto),
            decoration: InputDecoration(
              hintText: dica,
              hintStyle: TextStyle(color: corDica),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        )
      ],
    );
  }
}
