import 'package:flutter/material.dart';
import '../main.dart' show themeNotifier;
import '../theme/app_theme.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final boxBgColor = isDarkMode ? AppColors.darkBgSecondary : AppColors.lightBgSecondary;
    final boxBorderColor = isDarkMode ? AppColors.darkBorderUi : AppColors.lightBorderUi;
    final primaryTextColor = isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return InkWell(
      onTap: () => themeNotifier.toggle(),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: boxBgColor.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: boxBorderColor),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Icon(
          isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          color: primaryTextColor,
        ),
      ),
    );
  }
}
