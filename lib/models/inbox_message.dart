/// Representa uma mensagem na Caixa de Entrada (Notificações) do usuário.
/// Utilizada na tela de notificações para exibir alertas sobre a situação da inscrição.
class InboxMessage {
  final int id;
  final String title;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  InboxMessage({
    required this.id,
    required this.title,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  /// Cria uma instância de [InboxMessage] a partir de um mapa de dados JSON recebido da API.
  factory InboxMessage.fromJson(Map<String, dynamic> json) {
    return InboxMessage(
      id: json['id'],
      title: json['title'] ?? 'Sem Título',
      content: json['content'] ?? '',
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
