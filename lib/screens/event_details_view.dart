import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/event.dart';
import '../theme/app_theme.dart';

/// Tela de detalhes da atividade — com seleção de setor e modal de pagamento
class EventDetailsView extends StatefulWidget {
  final Event event;
  final VoidCallback onBack;
  final void Function({int? sectorId}) onSubscribe;

  const EventDetailsView({
    super.key,
    required this.event,
    required this.onBack,
    required this.onSubscribe,
  });

  @override
  State<EventDetailsView> createState() => _EventDetailsViewState();
}

class _EventDetailsViewState extends State<EventDetailsView> {
  int? _selectedSectorId;
  bool _showPaymentModal = false;

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

  bool get _isServo =>
      widget.event.isServantRegistrationOpen &&
      !widget.event.isCamperRegistrationOpen;

  bool get _canSubscribe {
    if (_isServo && widget.event.categorySectors.isNotEmpty) {
      return _selectedSectorId != null;
    }
    return true;
  }

  void _handleSubscribeClick() {
    if (widget.event.fee > 0) {
      setState(() => _showPaymentModal = true);
    } else {
      _finalizeSubscription();
    }
  }

  void _finalizeSubscription() {
    setState(() => _showPaymentModal = false);
    widget.onSubscribe(sectorId: _selectedSectorId);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgSecondary = isDark
        ? AppColors.darkBgSecondary
        : AppColors.lightBgSecondary;
    final bgPrimary = isDark
        ? AppColors.darkBgPrimary
        : AppColors.lightBgPrimary;
    final borderColor = isDark
        ? AppColors.darkBorderUi
        : AppColors.lightBorderUi;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final event = widget.event;
    final notice = event.activitable?['notice'];
    final term = event.activitable?['term'];
    final endDateStr = event.endDate != null
        ? DateFormat('dd/MM/yyyy').format(event.endDate!)
        : 'Não definida';

    final statusLabel = event.registrationStatusLabel;
    final bool isOpen = event.isRegistrationOpen;
    final bool isFuture = !isOpen && event.nextRegistrationStartDate != null;
    final Color statusColor = isOpen
        ? AppColors.brand
        : isFuture
        ? Colors.orange
        : Colors.grey;
    final Color statusBg = statusColor.withValues(alpha: 0.1);
    final Color statusBorder = statusColor.withValues(alpha: 0.2);

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Botão de voltar
            TextButton.icon(
              onPressed: widget.onBack,
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                size: 16,
                color: textSecondary,
              ),
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
                  // Header — nome + status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.name,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: textPrimary,
                              ),
                            ),
                            if (event.categoryName != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                event.categoryName!,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: statusBg,
                          border: Border.all(color: statusBorder),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: statusColor,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(color: borderColor, height: 32),

                  // Linhas de informação
                  _InfoRow(
                    label: 'LOCAL',
                    value: event.place ?? 'Não informado',
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                  _InfoRow(
                    label: 'INÍCIO',
                    value: _formatDate(event.startDate),
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                  _InfoRow(
                    label: 'TÉRMINO',
                    value: endDateStr,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                  if (!event.isCamping)
                    _InfoRow(
                      label: 'VAGAS',
                      value: event.totalVacancies?.toString() ?? 'Ilimitadas',
                      borderColor: borderColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  _InfoRow(
                    label: 'VALOR',
                    value: _formatFee(event.fee),
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    valueColor: AppColors.brand,
                    valueFontSize: 18,
                  ),
                  // Faixa de idade (acampamento)
                  if (event.isCamping &&
                      event.minimalAge != null &&
                      event.maximalAge != null)
                    _InfoRow(
                      label: 'IDADE',
                      value: '${event.minimalAge} - ${event.maximalAge} anos',
                      borderColor: borderColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  if (!event.isCamping && event.minimalAge != null)
                    _InfoRow(
                      label: 'IDADE MÍNIMA',
                      value: '${event.minimalAge} anos',
                      borderColor: borderColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
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

                  // Seleção de setor (apenas para servos)
                  if (_isServo && event.categorySectors.isNotEmpty) ...[
                    Divider(color: borderColor, height: 32),
                    Text(
                      'PREFERÊNCIA DE SETOR',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: bgPrimary,
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int?>(
                          isExpanded: true,
                          value: _selectedSectorId,
                          hint: Text(
                            'Selecione...',
                            style: TextStyle(color: textSecondary),
                          ),
                          dropdownColor: bgSecondary,
                          style: TextStyle(color: textPrimary, fontSize: 14),
                          items: [
                            DropdownMenuItem<int?>(
                              value: -1,
                              child: Text(
                                'Sem setor de preferência',
                                style: TextStyle(color: textPrimary),
                              ),
                            ),
                            ...event.categorySectors.map(
                              (sector) => DropdownMenuItem<int?>(
                                value: sector['id'] as int,
                                child: Text(
                                  sector['name'] ?? 'Setor',
                                  style: TextStyle(color: textPrimary),
                                ),
                              ),
                            ),
                          ],
                          onChanged: (val) => setState(() {
                            _selectedSectorId = val;
                          }),
                        ),
                      ),
                    ),
                  ],

                  Divider(color: borderColor, height: 32),

                  // Botões de ação (Edital / Termos)
                  if (notice != null || term != null)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (notice != null)
                          OutlinedButton(
                            onPressed: () => _openUrl(notice),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: borderColor),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: borderColor),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
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
                        onPressed: _canSubscribe ? _handleSubscribeClick : null,
                        icon: const Icon(Icons.how_to_reg_rounded, size: 20),
                        label: const Text('SE INSCREVER'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Modal de pagamento PIX
        if (_showPaymentModal)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _showPaymentModal = false),
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: GestureDetector(
                    onTap: () {}, // impedir propagação
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: bgPrimary,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Pagamento da Inscrição',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Valor: ${_formatFee(event.fee)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: textSecondary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Simulação PIX
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: bgSecondary,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: borderColor),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Simulação de Pagamento via PIX',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: borderColor,
                                      width: 3,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'QR CODE',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.5,
                                        color: borderColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _finalizeSubscription,
                              child: const Text('SIMULAR PAGAMENTO'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () =>
                                  setState(() => _showPaymentModal = false),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(color: borderColor),
                              ),
                              child: Text(
                                'CANCELAR',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                  letterSpacing: 1,
                                  color: textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
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
