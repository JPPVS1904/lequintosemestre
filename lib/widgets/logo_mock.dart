import 'package:flutter/material.dart';

class LogoMock extends StatelessWidget {
  final Color cor;

  const LogoMock({super.key, required this.cor});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'lib/images/logo_comunidade_sao_miguel.png',
      height: 300,
    );
  }
}
