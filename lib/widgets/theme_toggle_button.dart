import 'package:flutter/material.dart';
import '../theme/theme_notifier.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final bool modoEscuro = Theme.of(context).brightness == Brightness.dark;
    final boxBgColor = modoEscuro ? const Color(0xFF16191C) : const Color(0xFFF2EDE4);
    final boxBorderColor = modoEscuro ? const Color(0xFF2A2D31) : const Color(0xFFD9D3C8);
    final corTextoPrincipal = modoEscuro ? const Color(0xFFF0F2F5) : const Color(0xFF1A1C1E);

    return InkWell(
      onTap: () {
        modoEscuroNotifier.value = !modoEscuroNotifier.value;
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: boxBgColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: boxBorderColor),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Icon(
          modoEscuro ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          color: corTextoPrincipal,
        ),
      ),
    );
  }
}
