import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/event.dart';
import '../theme/app_theme.dart';

// Tela de detalhes do evento
class EventDetailsView extends StatelessWidget {
  final Event event;
  final VoidCallback onBack;
  final VoidCallback onSubscribe;

  const EventDetailsView({
    super.key,
    required this.event,
    required this.onBack,
    required this.onSubscribe,
  });

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Não definida';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return 'Não definida';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatFee(double fee) {
    if (fee <= 0) return 'Gratuito';
    return 'R\$ ${fee.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgSecondary = isDark ? AppColors.darkBgSecondary : AppColors.lightBgSecondary;
    final borderColor = isDark ? AppColors.darkBorderUi : AppColors.lightBorderUi;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final notice = event.eventable?['notice'];
    final term = event.eventable?['term'];
    final endDateStr = event.endDate != null
        ? DateFormat('dd/MM/yyyy').format(event.endDate!)
        : 'Não definida';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Botão de voltar
        TextButton.icon(
          onPressed: onBack,
          icon: Icon(Icons.arrow_back_ios_rounded, size: 16, color: textSecondary),
          label: Text(
            'VOLTAR PARA LISTA',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Card principal
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: bgSecondary,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      event.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.brand.withValues(alpha: 0.1),
                      border: Border.all(color: AppColors.brand.withValues(alpha: 0.2)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'INSCRIÇÕES ABERTAS',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppColors.brand,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(color: borderColor, height: 32),

              // Linhas de informação
              _InfoRow(label: 'LOCAL', value: event.place ?? 'Não informado', borderColor: borderColor, textPrimary: textPrimary, textSecondary: textSecondary),
              _InfoRow(label: 'INÍCIO', value: _formatDate(event.startDate), borderColor: borderColor, textPrimary: textPrimary, textSecondary: textSecondary),
              _InfoRow(label: 'TÉRMINO', value: endDateStr, borderColor: borderColor, textPrimary: textPrimary, textSecondary: textSecondary),
              _InfoRow(label: 'VAGAS', value: event.totalVacancies?.toString() ?? 'Ilimitadas', borderColor: borderColor, textPrimary: textPrimary, textSecondary: textSecondary),
              _InfoRow(
                label: 'VALOR',
                value: _formatFee(event.fee),
                borderColor: borderColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                valueColor: AppColors.brand,
                valueFontSize: 18,
              ),

              // Imagem
              if (event.image != null) ...[
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    event.image!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: borderColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          'SEM IMAGEM',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            color: textSecondary.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              Divider(color: borderColor, height: 32),

              // Botões de ação
              if (notice != null || term != null)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (notice != null)
                      OutlinedButton(
                        onPressed: () => _openUrl(notice),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: borderColor),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                        child: Text(
                          'EDITAL',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: textPrimary,
                          ),
                        ),
                      ),
                    if (term != null)
                      OutlinedButton(
                        onPressed: () => _openUrl(term),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: borderColor),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                        child: Text(
                          'TERMOS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: textPrimary,
                          ),
                        ),
                      ),
                  ],
                ),
              const SizedBox(height: 16),

              // Botão de inscrição
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brand.withValues(alpha: 0.2),
                        offset: const Offset(0, 6),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: onSubscribe,
                    icon: const Icon(Icons.how_to_reg_rounded, size: 20),
                    label: const Text('SE INSCREVER'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color? valueColor;
  final double? valueFontSize;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
    this.valueColor,
    this.valueFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: textSecondary,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: valueFontSize ?? 14,
                fontWeight: FontWeight.w900,
                color: valueColor ?? textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
