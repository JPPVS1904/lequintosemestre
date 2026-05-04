import 'package:flutter/material.dart';

class LoginDrawer extends StatelessWidget {
  const LoginDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final sidebarBgColor = isDarkMode ? const Color(0xFF0D0F11) : const Color(0xFFF2EDE4);
    final sidebarItemHover = const Color(0xFFC4982A).withOpacity(0.1);
    final primaryTextColor = isDarkMode ? const Color(0xFFF0F2F5) : const Color(0xFF1A1C1E);
    final secondaryTextColor = isDarkMode ? const Color(0xFF9BA1A6) : const Color(0xFF44474A);
    final boxBorderColor = isDarkMode ? const Color(0xFF2A2D31) : const Color(0xFFD9D3C8);

    return Drawer(
      backgroundColor: sidebarBgColor,
      child: Column(
        children: [
          const SizedBox(height: 100),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: sidebarItemHover,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.location_on_outlined, color: primaryTextColor),
            ),
            title: Text('Onde Estamos', style: TextStyle(fontWeight: FontWeight.bold, color: primaryTextColor)),
            onTap: () {
              // Open Maps
            },
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: sidebarItemHover,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.camera_alt_outlined, color: primaryTextColor),
            ),
            title: Text('Instagram', style: TextStyle(fontWeight: FontWeight.bold, color: primaryTextColor)),
            subtitle: Text('SEGUIR @CAMPISTAS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: secondaryTextColor)),
            onTap: () {
              // Open Instagram
            },
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: boxBorderColor.withOpacity(0.3))),
              color: isDarkMode ? const Color(0xFF16191C).withOpacity(0.5) : const Color(0xFFEAE4D9).withOpacity(0.5),
            ),
            child: Center(
              child: Text(
                'COMUNIDADE \nSÃO MIGUEL ARCANJO',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: secondaryTextColor.withOpacity(0.6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
