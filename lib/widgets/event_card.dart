import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../theme/app_theme.dart';

/// Card de exibição de uma Atividade/Evento.
/// Utilizado na listagem da tela principal para mostrar informações de forma resumida
/// como data, local, número de vagas disponíveis e preço da inscrição.
class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTapDetails;

  const EventCard({super.key, required this.event, required this.onTapDetails});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgSecondary = isDark
        ? AppColors.darkBgSecondary
        : AppColors.lightBgSecondary;
    final borderColor = isDark
        ? AppColors.darkBorderUi
        : AppColors.lightBorderUi;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final bgPrimary = isDark
        ? AppColors.darkBgPrimary
        : AppColors.lightBgPrimary;

    final formattedDate = event.startDate != null
        ? DateFormat('dd/MM/yyyy').format(DateTime.parse(event.startDate!))
        : null;

    final feeValue = event.fee;
    final feeText = feeValue > 0
        ? 'R\$ ${feeValue.toStringAsFixed(2).replaceAll('.', ',')}'
        : 'Gratuito';
    final feeColor = feeValue > 0 ? AppColors.brand : const Color(0xFF22C55E);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgSecondary,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título e badge de tipo
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  event.name.isNotEmpty ? event.name : 'Atividade',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.brand.withValues(alpha: 0.1),
                  border: Border.all(
                    color: AppColors.brand.withValues(alpha: 0.2),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  event.typeLabel.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppColors.brand,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),

          // Categoria
          if (event.categoryName != null) ...[
            const SizedBox(height: 6),
            Text(
              event.categoryName!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Grid de informações
          Wrap(
            spacing: 16,
            runSpacing: 10,
            children: [
              // Data
              if (formattedDate != null)
                _InfoChip(
                  icon: Icons.calendar_today_rounded,
                  text: formattedDate,
                  color: textSecondary,
                ),
              // Local
              if (event.place != null && event.place!.isNotEmpty)
                _InfoChip(
                  icon: Icons.location_on_outlined,
                  text: event.place!,
                  color: textSecondary,
                  maxWidth: 120,
                ),
              // Vagas
              _InfoChip(
                icon: Icons.people_outline_rounded,
                text: event.totalVacancies != null && event.totalVacancies! > 0
                    ? '${event.totalVacancies} vagas'
                    : 'Vagas ilimitadas',
                color: textSecondary,
              ),
              // Preço
              _InfoChip(
                icon: Icons.attach_money_rounded,
                text: feeText,
                color: feeColor,
                bold: true,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Rodapé
          Container(
            padding: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: borderColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: onTapDetails,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: textPrimary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      'VER DETALHES',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: bgPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip de informação compacto com ícone
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final bool bold;
  final double? maxWidth;

  const _InfoChip({
    required this.icon,
    required this.text,
    required this.color,
    this.bold = false,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth ?? 150),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
