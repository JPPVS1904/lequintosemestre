import 'package:flutter/material.dart';

class FooterText extends StatelessWidget {
  final Color secondaryTextColor;
  final Color highlightColor;

  const FooterText({
    super.key,
    required this.secondaryTextColor,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Novo por aqui? ',
          style: TextStyle(color: secondaryTextColor, fontSize: 13),
        ),
        GestureDetector(
          onTap: () {},
          child: Text(
            'Crie sua conta',
            style: TextStyle(
              color: highlightColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
