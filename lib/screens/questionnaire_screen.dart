import 'package:flutter/material.dart';
import '../services/event_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_modal.dart';

/// Tela de preenchimento do questionário de inscrição.
/// Renderiza dinamicamente as perguntas vindas da API (texto ou múltipla escolha).
class QuestionnaireScreen extends StatefulWidget {
  final int preRegistrationId;
  final VoidCallback onBack;
  final VoidCallback onSuccess;

  const QuestionnaireScreen({
    super.key,
    required this.preRegistrationId,
    required this.onBack,
    required this.onSuccess,
  });

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final _eventService = EventService();

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;

  Map<String, dynamic>? _preRegistration;
  List<Map<String, dynamic>> _questions = [];

  // Respostas: questionId -> String (aberta/única) ou List<String> (múltipla)
  final Map<int, dynamic> _formData = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Buscar detalhes da inscrição
      final sub = await _eventService.fetchSubscriptionDetail(
        widget.preRegistrationId,
      );
      if (sub == null) {
        setState(() {
          _error = 'Erro ao buscar detalhes da inscrição.';
          _isLoading = false;
        });
        return;
      }

      _preRegistration = sub;

      final event = sub['event'] as Map<String, dynamic>?;
      final category = event?['category'] as Map<String, dynamic>?;

      if (category == null) {
        setState(() {
          _error =
              'A atividade desta inscrição não possui uma categoria com perguntas.';
          _isLoading = false;
        });
        return;
      }

      final categoryId = category['id'] as int;
      final questions = await _eventService.fetchQuestions(categoryId);

      // Inicializar formData
      for (final q in questions) {
        final qId = q['id'] as int;
        final type = q['type'] ?? '';
        if (type == 'Fechada (Múltipla Escolha)') {
          _formData[qId] = <String>[];
        } else {
          _formData[qId] = '';
        }
      }

      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _requestSubmit() async {
    final confirmed = await showAppModal(
      context,
      type: 'confirm',
      message:
          'Tem certeza que deseja enviar o formulário? Após o envio, as respostas não poderão ser alteradas.',
    );
    if (confirmed != true) return;
    _performSubmit();
  }

  Future<void> _performSubmit() async {
    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final answersArray = _questions.map((q) {
      final qId = q['id'] as int;
      var ans = _formData[qId];
      if (ans is List) {
        ans = ans.join(', ');
      }
      return {'question_id': qId, 'answer': ans.toString()};
    }).toList();

    final result = await _eventService.submitAnswers(
      widget.preRegistrationId,
      answersArray,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result['success'] == true) {
      await showAppModal(
        context,
        type: 'success',
        message:
            'Respostas enviadas com sucesso! Aguarde a avaliação dos conselheiros.',
      );
      widget.onSuccess();
    } else {
      setState(() => _error = result['message'] ?? 'Erro ao enviar respostas.');
    }
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
    final bgPrimary = isDark
        ? AppColors.darkBgPrimary
        : AppColors.lightBgPrimary;
    final borderColor = isDark
        ? AppColors.darkBorderUi
        : AppColors.lightBorderUi;

    final eventName =
        (_preRegistration?['event'] as Map<String, dynamic>?)?['name'] ?? '';
    final categoryName =
        ((_preRegistration?['event'] as Map<String, dynamic>?)?['category']
            as Map<String, dynamic>?)?['name'] ??
        '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Voltar
          TextButton.icon(
            onPressed: widget.onBack,
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              size: 16,
              color: textSecondary,
            ),
            label: Text(
              'VOLTAR',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Título
          Text(
            'Formulário de Inscrição',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: textPrimary,
            ),
          ),
          if (_preRegistration != null) ...[
            const SizedBox(height: 4),
            Text(
              '$categoryName - $eventName',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.brand,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            'Responda o questionário abaixo para prosseguir com a confirmação da sua inscrição.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Conteúdo
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: CircularProgressIndicator(color: AppColors.brand),
              ),
            )
          else if (_error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                border: Border.all(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _error!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEF4444),
                ),
              ),
            )
          else if (_questions.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 60),
              decoration: BoxDecoration(
                color: bgSecondary,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: borderColor, width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    'NENHUMA PERGUNTA CONFIGURADA',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: textSecondary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: widget.onBack,
                    child: const Text('VOLTAR'),
                  ),
                ],
              ),
            )
          else
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
                  // Perguntas
                  ..._questions.asMap().entries.map((entry) {
                    final q = entry.value;
                    final qId = q['id'] as int;
                    final text = q['text'] ?? '';
                    final type = q['type'] ?? 'Aberta';
                    final options =
                        (q['options'] as List?)
                            ?.map((o) => Map<String, dynamic>.from(o))
                            .toList() ??
                        [];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Texto da pergunta
                          RichText(
                            text: TextSpan(
                              text: text,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: textPrimary,
                              ),
                              children: const [
                                TextSpan(
                                  text: ' *',
                                  style: TextStyle(color: AppColors.brand),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Opções de resposta
                          if (type == 'Fechada (Única Escolha)' &&
                              options.isNotEmpty)
                            ...options.map((opt) {
                              final optText = opt['text'] ?? '';
                              final isSelected = _formData[qId] == optText;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _formData[qId] = optText),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.brand.withValues(
                                            alpha: 0.08,
                                          )
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.brand.withValues(
                                              alpha: 0.4,
                                            )
                                          : borderColor,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.brand
                                                : textSecondary,
                                            width: 2,
                                          ),
                                        ),
                                        child: isSelected
                                            ? Center(
                                                child: Container(
                                                  width: 10,
                                                  height: 10,
                                                  decoration:
                                                      const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: AppColors.brand,
                                                      ),
                                                ),
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          optText,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: textPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            })
                          else if (type == 'Fechada (Múltipla Escolha)' &&
                              options.isNotEmpty)
                            ...options.map((opt) {
                              final optText = opt['text'] ?? '';
                              final selectedList =
                                  _formData[qId] as List<String>? ?? [];
                              final isChecked = selectedList.contains(optText);
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    final list = List<String>.from(
                                      _formData[qId] as List? ?? [],
                                    );
                                    if (isChecked) {
                                      list.remove(optText);
                                    } else {
                                      list.add(optText);
                                    }
                                    _formData[qId] = list;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: isChecked
                                        ? AppColors.brand.withValues(
                                            alpha: 0.08,
                                          )
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isChecked
                                          ? AppColors.brand.withValues(
                                              alpha: 0.4,
                                            )
                                          : borderColor,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          border: Border.all(
                                            color: isChecked
                                                ? AppColors.brand
                                                : textSecondary,
                                            width: 2,
                                          ),
                                          color: isChecked
                                              ? AppColors.brand
                                              : Colors.transparent,
                                        ),
                                        child: isChecked
                                            ? const Icon(
                                                Icons.check,
                                                size: 14,
                                                color: Colors.white,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          optText,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: textPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            })
                          else
                            // Pergunta aberta — textarea
                            TextField(
                              maxLines: 4,
                              onChanged: (val) => _formData[qId] = val,
                              decoration: InputDecoration(
                                hintText: 'Digite sua resposta...',
                                fillColor: bgPrimary,
                              ),
                            ),
                        ],
                      ),
                    );
                  }),

                  Divider(color: borderColor, height: 32),

                  // Botão enviar
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
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
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _requestSubmit,
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text('ENVIAR RESPOSTAS'),
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
