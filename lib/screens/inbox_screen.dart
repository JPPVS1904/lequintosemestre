import 'package:flutter/material.dart';
import '../models/inbox_message.dart';
import '../services/event_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_modal.dart';

/// Tela de Caixa de Entrada (Notificações).
/// Exibe a lista de alertas do usuário, permitindo ler mensagens enviadas pelo sistema.
class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final _eventService = EventService();
  bool _isLoading = true;
  List<InboxMessage> _messages = [];
  InboxMessage? _selectedMessage;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    setState(() => _isLoading = true);
    final data = await _eventService.fetchInboxMessages();
    setState(() {
      _messages = data.map((e) => InboxMessage.fromJson(e)).toList();
      _isLoading = false;
    });
  }

  Future<void> _markAsRead(InboxMessage msg) async {
    if (msg.isRead) return;
    final success = await _eventService.markInboxMessageAsRead(msg.id);
    if (success) _fetchMessages();
  }

  Future<void> _markAllAsRead() async {
    final success = await _eventService.markAllInboxMessagesAsRead();
    if (success) _fetchMessages();
  }

  Future<void> _deleteMessage(int id) async {
    final confirm = await showAppModal(
      context,
      type: 'confirm',
      message: 'Deseja excluir esta notificação?',
    );
    if (confirm == true) {
      final success = await _eventService.deleteInboxMessage(id);
      if (success) _fetchMessages();
    }
  }

  void _openMessage(InboxMessage msg) {
    _markAsRead(msg);
    setState(() => _selectedMessage = msg);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final bgSecondary = isDark
        ? AppColors.darkBgSecondary
        : AppColors.lightBgSecondary;
    final borderColor = isDark
        ? AppColors.darkBorderUi
        : AppColors.lightBorderUi;

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.brand),
            const SizedBox(height: 16),
            Text(
              'Buscando notificações...',
              style: TextStyle(color: textPrimary.withValues(alpha: 0.6)),
            ),
          ],
        ),
      );
    }

    if (_selectedMessage != null) {
      return _buildMessageDetail(
        textPrimary,
        textSecondary,
        bgSecondary,
        borderColor,
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchMessages,
      color: AppColors.brand,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Caixa de Entrada',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: textPrimary,
                ),
              ),
              if (_messages.any((m) => !m.isRead))
                TextButton.icon(
                  onPressed: _markAllAsRead,
                  icon: const Icon(Icons.done_all_rounded, size: 16),
                  label: const Text(
                    'Marcar todas como lidas',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          if (_messages.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: borderColor, width: 2),
              ),
              child: Text(
                'SUA CAIXA DE ENTRADA ESTÁ VAZIA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: textSecondary,
                  letterSpacing: 1.5,
                ),
              ),
            )
          else
            ..._messages.map((msg) {
              final isUnread = !msg.isRead;
              return GestureDetector(
                onTap: () => _openMessage(msg),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isUnread
                        ? AppColors.brand.withValues(alpha: 0.1)
                        : bgSecondary,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isUnread
                          ? AppColors.brand.withValues(alpha: 0.3)
                          : borderColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUnread
                              ? AppColors.brand.withValues(alpha: 0.2)
                              : bgSecondary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isUnread
                              ? Icons.mark_email_unread_rounded
                              : Icons.mark_email_read_rounded,
                          color: isUnread ? AppColors.brand : textSecondary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isUnread
                                    ? FontWeight.w900
                                    : FontWeight.w700,
                                color: textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(msg.createdAt),
                              style: TextStyle(
                                fontSize: 11,
                                color: textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _deleteMessage(msg.id),
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: textSecondary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildMessageDetail(
    Color textPrimary,
    Color textSecondary,
    Color bgSecondary,
    Color borderColor,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: bgSecondary,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => setState(() => _selectedMessage = null),
                  icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
                Text(
                  'Voltar para Caixa de Entrada',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              _selectedMessage!.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Recebida em: ${_formatDate(_selectedMessage!.createdAt)}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textSecondary,
              ),
            ),
            Divider(color: borderColor, height: 40),
            Text(
              _selectedMessage!.content,
              style: TextStyle(fontSize: 15, height: 1.6, color: textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
