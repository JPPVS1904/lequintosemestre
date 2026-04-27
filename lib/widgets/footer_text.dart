import 'package:flutter/material.dart';

class FooterText extends StatelessWidget {
  final Color corTextoSecundario;
  final Color corDestaque;

  const FooterText({
    super.key,
    required this.corTextoSecundario,
    required this.corDestaque,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Novo por aqui? ',
          style: TextStyle(color: corTextoSecundario, fontSize: 13),
        ),
        GestureDetector(
          onTap: () {},
          child: Text(
            'Crie sua conta',
            style: TextStyle(
              color: corDestaque,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
