import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

/// Menu lateral principal do aplicativo (Drawer).
/// Responsável por navegar entre as abas principais (Painel Geral, Minhas Inscrições, Notificações e Perfil).
/// Recebe [activeTab] para destacar o item selecionado e [onTabSelected] para comunicar a mudança ao [DashboardScreen].
class AppDrawer extends StatelessWidget {
  final String activeTab;
  final Function(String) onTabSelected;

  const AppDrawer({
    super.key,
    required this.activeTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.darkBgSecondary
        : AppColors.lightBgSecondary;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final borderColor = isDark
        ? AppColors.darkBorderUi
        : AppColors.lightBorderUi;

    return Drawer(
      backgroundColor: bgColor,
      child: Column(
        children: [
          // Área do Logo
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

          // Navegação
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _NavItem(
                  icon: Icons.event_rounded,
                  label: 'Atividades',
                  isActive: activeTab == 'events',
                  onTap: () {
                    onTabSelected('events');
                    Navigator.pop(context);
                  },
                ),
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
                  icon: Icons.notifications_rounded,
                  label: 'Notificações',
                  isActive: activeTab == 'inbox',
                  onTap: () {
                    onTabSelected('inbox');
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

          // Sair
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
                  icon: const Icon(
                    Icons.logout_rounded,
                    size: 18,
                    color: Colors.redAccent,
                  ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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

/// Item de navegação único para a barra lateral
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
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

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
