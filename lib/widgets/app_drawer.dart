import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

/// Dashboard sidebar drawer matching Sidebar.svelte
/// Items: Eventos, [Admin: Usuários, Criar Evento], Minhas Inscrições, Perfil, Sair
class AppDrawer extends StatelessWidget {
  final String activeTab;
  final bool isAdmin;
  final Function(String) onTabSelected;
  final VoidCallback? onAddEvent;

  const AppDrawer({
    super.key,
    required this.activeTab,
    required this.isAdmin,
    required this.onTabSelected,
    this.onAddEvent,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBgSecondary : AppColors.lightBgSecondary;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final borderColor = isDark ? AppColors.darkBorderUi : AppColors.lightBorderUi;

    return Drawer(
      backgroundColor: bgColor,
      child: Column(
        children: [
          // ── Logo area ──
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Image.asset(
                'lib/images/logo_comunidade_sao_miguel.png',
                height: 100,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.shield_rounded,
                  size: 60,
                  color: AppColors.brand,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ── Navigation ──
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _NavItem(
                  icon: Icons.event_rounded,
                  label: 'Eventos',
                  isActive: activeTab == 'events',
                  onTap: () {
                    onTabSelected('events');
                    Navigator.pop(context);
                  },
                ),
                if (isAdmin) ...[
                  _NavItem(
                    icon: Icons.add_rounded,
                    label: 'Criar Evento',
                    isActive: activeTab == 'event_form',
                    onTap: () {
                      if (onAddEvent != null) onAddEvent!();
                      Navigator.pop(context);
                    },
                  ),
                ],
                _NavItem(
                  icon: Icons.assignment_rounded,
                  label: 'Minhas Inscrições',
                  isActive: activeTab == 'subscriptions',
                  onTap: () {
                    onTabSelected('subscriptions');
                    Navigator.pop(context);
                  },
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Perfil',
                  isActive: activeTab == 'profile',
                  onTap: () {
                    onTabSelected('profile');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),

          // ── Logout ──
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: borderColor)),
              ),
              padding: const EdgeInsets.only(top: 12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await AuthService.logout();
                    if (!context.mounted) return;
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  icon: const Icon(Icons.logout_rounded, size: 18, color: Colors.redAccent),
                  label: Text(
                    'Sair',
                    style: TextStyle(
                      color: textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: textPrimary.withValues(alpha: 0.2)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Single navigation item for the drawer
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isActive ? AppColors.brand : Colors.transparent,
        leading: Icon(
          icon,
          size: 20,
          color: isActive ? Colors.white : textSecondary,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isActive ? Colors.white : textSecondary,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
