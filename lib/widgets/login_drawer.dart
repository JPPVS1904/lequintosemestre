import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

/// Login sidebar drawer matching Login.svelte's sidebar
/// Contains: "Onde Estamos" (Maps link) and "Instagram" link
class LoginDrawer extends StatelessWidget {
  const LoginDrawer({super.key});

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBgPrimary : AppColors.lightBgPrimary;
    final bgSecondary = isDark ? AppColors.darkBgSecondary : AppColors.lightBgSecondary;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.darkBorderUi : AppColors.lightBorderUi;

    return Drawer(
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(0)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 100),

          // ── Onde Estamos ──
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bgSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.location_on_outlined, color: textPrimary, size: 20),
            ),
            title: Text(
              'Onde Estamos',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: textPrimary),
            ),
            onTap: () => _openUrl(
              'https://www.google.com/maps/search/?api=1&query=Av.+Mato+Grosso,+415+-+Primavera+II,+Primavera+do+Leste+-+MT,+78850-000',
            ),
          ),

          const SizedBox(height: 4),

          // ── Instagram ──
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bgSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.camera_alt_outlined, color: textPrimary, size: 20),
            ),
            title: Text(
              'Instagram',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: textPrimary),
            ),
            subtitle: Text(
              'SEGUIR @CAMPISTAS',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: textSecondary.withValues(alpha: 0.4),
                letterSpacing: 1.5,
              ),
            ),
            onTap: () => _openUrl('https://www.instagram.com/campistasprimavera/'),
          ),

          const Spacer(),

          // ── Footer ──
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: borderColor.withValues(alpha: 0.3))),
              color: bgSecondary.withValues(alpha: 0.2),
            ),
            child: Center(
              child: Text(
                'COMUNIDADE\nSÃO MIGUEL ARCANJO',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: textSecondary.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
