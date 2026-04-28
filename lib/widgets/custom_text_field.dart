import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
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
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _ocultaSenha;

  @override
  void initState() {
    super.initState();
    _ocultaSenha = widget.senha;
  }

  @override
  Widget build(BuildContext context) {
    final corRotulo = widget.modoEscuro ? const Color(0xFFCCCCCC) : const Color(0xFF4A4A4A);
    final corFundo = widget.modoEscuro ? const Color(0xFF252525) : const Color(0xFFEBE4D5);
    final corSombra = widget.modoEscuro ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.08);
    final corTexto = widget.modoEscuro ? Colors.white : Colors.black87;
    final corDica = widget.modoEscuro ? Colors.grey[600] : const Color(0xFF9E9E9E);
    final corIcone = widget.modoEscuro ? Colors.grey[400] : Colors.grey[600];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.rotulo.toUpperCase(),
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
                color: corSombra,
                offset: const Offset(0, 2),
                blurRadius: 6,
              ),
            ],
          ),
          child: TextField(
            controller: widget.controlador,
            obscureText: _ocultaSenha,
            style: TextStyle(color: corTexto),
            decoration: InputDecoration(
              hintText: widget.dica,
              hintStyle: TextStyle(color: corDica),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              suffixIcon: widget.senha
                  ? IconButton(
                      icon: Icon(
                        _ocultaSenha ? Icons.visibility_off : Icons.visibility,
                        color: corIcone,
                      ),
                      onPressed: () {
                        setState(() {
                          _ocultaSenha = !_ocultaSenha;
                        });
                      },
                    )
                  : null,
            ),
          ),
        )
      ],
    );
  }
}

