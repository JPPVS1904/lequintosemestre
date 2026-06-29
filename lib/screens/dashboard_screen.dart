import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_modal.dart';
import '../widgets/event_card.dart';
import 'event_details_view.dart';
import 'questionnaire_screen.dart';
import 'inbox_screen.dart';

/// Formatador de número de telefone celular e fixo.
/// Aplica dinamicamente a máscara `(XX) XXXXX-XXXX` ou `(XX) XXXX-XXXX` enquanto o usuário digita.
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 11) digits = digits.substring(0, 11);

    String formatted = '';
    if (digits.isNotEmpty) {
      formatted = '(';
      for (int i = 0; i < digits.length; i++) {
        if (i == 2) formatted += ') ';
        if (digits.length == 11 && i == 7) formatted += '-';
        if (digits.length < 11 && i == 6) formatted += '-';
        formatted += digits[i];
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Tela Principal (Dashboard) do aplicativo.
/// Gerencia a navegação entre as abas principais através do [AppDrawer].
/// Abas suportadas: 'events', 'subscriptions', 'profile', 'event_details', 'questionnaire', 'inbox'.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _eventService = EventService();

  String _activeTab = 'events';
  bool _isLoading = true;
  Map<String, dynamic> _userData = {};
  List<Event> _events = [];
  List<Map<String, dynamic>> _subscriptions = [];
  Event? _selectedEvent;
  int? _selectedSubscriptionId;

  String _eventSearchQuery = '';
  String _subSearchQuery = '';
  String _typeFilter = 'all'; // "all", "camping", "event"

  final _profileNameController = TextEditingController();
  final _profileEmailController = TextEditingController();
  final _profilePhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  String _formatPhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';
    String formatted = '(';
    for (int i = 0; i < digits.length; i++) {
      if (i == 2) formatted += ') ';
      if (digits.length == 11 && i == 7) formatted += '-';
      if (digits.length < 11 && i == 6) formatted += '-';
      formatted += digits[i];
    }
    return formatted;
  }

  Future<void> _initApp() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataStr = prefs.getString('user_data');
    if (userDataStr != null) {
      _userData = jsonDecode(userDataStr);
      _profileNameController.text = _userData['name'] ?? '';
      _profileEmailController.text = _userData['email'] ?? '';
      _profilePhoneController.text = _formatPhone(
        _userData['phone']?.toString() ?? '',
      );
    }
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    if (_activeTab == 'events') {
      _events = await _eventService.fetchEvents();
    } else if (_activeTab == 'subscriptions') {
      final rawId = _userData['id'];
      if (rawId != null) {
        final userId = rawId is int
            ? rawId
            : int.tryParse(rawId.toString()) ?? 0;
        _subscriptions = await _eventService.fetchSubscriptions(userId);
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _onTabSelected(String tab) {
    setState(() {
      _activeTab = tab;
      _selectedEvent = null;
      _selectedSubscriptionId = null;
    });
    if (tab != 'questionnaire') _fetchData();
  }

  void _openEventDetails(Event event) {
    setState(() {
      _selectedEvent = event;
      _activeTab = 'event_details';
    });
  }

  Future<void> _requestSubscription(Event event, {int? sectorId}) async {
    final subscriptionType = event.availableSubscriptionType;
    if (subscriptionType == null) {
      final nextDate = event.nextRegistrationStartDate;
      if (nextDate != null) {
        final d =
            '${nextDate.day.toString().padLeft(2, '0')}/${nextDate.month.toString().padLeft(2, '0')}/${nextDate.year}';
        showAppModal(
          context,
          type: 'error',
          message:
              'As inscrições para este evento ainda não começaram. Elas abrem em $d.',
        );
      } else {
        showAppModal(
          context,
          type: 'error',
          message: 'As inscrições para este evento estão encerradas.',
        );
      }
      return;
    }
    final confirmed = await showAppModal(
      context,
      type: 'confirm',
      message:
          'Ao confirmar, você será inscrito como $subscriptionType e redirecionado para suas inscrições. Deseja continuar?',
    );
    if (confirmed != true) return;
    final rawId = _userData['id'];
    final userId = rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0;

    // Se o setor é -1 (sem preferência), envia null
    final effectiveSectorId = sectorId == -1 ? null : sectorId;

    final result = await _eventService.subscribe(
      event.id,
      userId,
      subscriptionType: subscriptionType,
      sectorId: effectiveSectorId,
    );
    if (!mounted) return;
    if (result['success'] == true) {
      await showAppModal(
        context,
        type: 'success',
        message: 'Inscrição realizada com sucesso!',
      );
      _onTabSelected('subscriptions');
    } else {
      showAppModal(
        context,
        type: 'error',
        message: result['message'] ?? 'Erro ao se inscrever.',
      );
    }
  }

  Future<void> _updateProfile() async {
    final confirmed = await showAppModal(
      context,
      type: 'confirm',
      message: 'Deseja realmente salvar as alterações no seu perfil?',
    );
    if (confirmed != true) return;
    final payload = {
      'name': _profileNameController.text,
      'email': _profileEmailController.text,
      'phone': _profilePhoneController.text.replaceAll(RegExp(r'\D'), ''),
    };
    final cpf = _userData['cpf'] ?? _userData['document'];
    if (cpf != null) {
      payload['cpf'] = cpf.toString().replaceAll(RegExp(r'\D'), '');
    }
    final result = await _eventService.updateProfile(_userData['id'], payload);
    if (!mounted) return;
    if (result['success'] == true) {
      if (result['data'] != null) {
        _userData = {
          ..._userData,
          ...Map<String, dynamic>.from(result['data']),
        };
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(_userData));
      }
      if (!mounted) return;
      showAppModal(
        context,
        type: 'success',
        message: 'Perfil atualizado com sucesso!',
      );
    } else {
      if (!mounted) return;
      showAppModal(
        context,
        type: 'error',
        message: result['message'] ?? 'Erro ao atualizar.',
      );
    }
  }

  String get _appBarTitle {
    switch (_activeTab) {
      case 'events':
        return 'Atividades';
      case 'subscriptions':
        return 'Minhas Inscrições';
      case 'profile':
        return 'Perfil';
      case 'inbox':
        return 'Notificações';
      case 'event_details':
        return _selectedEvent?.name ?? 'Detalhes';
      case 'questionnaire':
        return 'Questionário';
      default:
        return 'Painel';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final bgPrimary = isDark
        ? AppColors.darkBgPrimary
        : AppColors.lightBgPrimary;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bgPrimary,
      drawer: AppDrawer(activeTab: _activeTab, onTabSelected: _onTabSelected),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu_rounded, color: textPrimary),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(_appBarTitle),
        actions: [],
      ),
      body: _activeTab == 'questionnaire' && _selectedSubscriptionId != null
          ? QuestionnaireScreen(
              preRegistrationId: _selectedSubscriptionId!,
              onBack: () => _onTabSelected('subscriptions'),
              onSuccess: () => _onTabSelected('subscriptions'),
            )
          : _isLoading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppColors.brand),
                  const SizedBox(height: 16),
                  Text(
                    'Buscando dados...',
                    style: TextStyle(color: textPrimary.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            )
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_activeTab) {
      case 'events':
        return _buildEventsTab();
      case 'subscriptions':
        return _buildSubscriptionsTab();
      case 'profile':
        return _buildProfileTab();
      case 'inbox':
        return const InboxScreen();
      case 'event_details':
        if (_selectedEvent != null) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: EventDetailsView(
              event: _selectedEvent!,
              onBack: () => _onTabSelected('events'),
              onSubscribe: ({int? sectorId}) =>
                  _requestSubscription(_selectedEvent!, sectorId: sectorId),
            ),
          );
        }
        return const SizedBox.shrink();
      default:
        return const SizedBox.shrink();
    }
  }

  // ABA DE EVENTOS
  Widget _buildEventsTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final borderColor = isDark
        ? AppColors.darkBorderUi
        : AppColors.lightBorderUi;
    final bgSecondary = isDark
        ? AppColors.darkBgSecondary
        : AppColors.lightBgSecondary;

    final filtered = _events.where((e) {
      // Filtro de busca
      final matchesSearch = e.name.toLowerCase().contains(
        _eventSearchQuery.toLowerCase(),
      );
      if (!matchesSearch) return false;

      // Filtro por tipo
      if (_typeFilter == 'camping' && !e.isCamping) return false;
      if (_typeFilter == 'event' && !e.isEvent) return false;

      // Ocultar atividades passadas para usuários comuns
      if (e.startDate != null) {
        final start = DateTime.tryParse(e.startDate!);
        if (start != null && start.isBefore(DateTime.now())) return false;
      }
      return true;
    }).toList();

    return RefreshIndicator(
      onRefresh: _fetchData,
      color: AppColors.brand,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            onChanged: (v) => setState(() => _eventSearchQuery = v),
            decoration: InputDecoration(
              hintText: 'Pesquisar por nome da atividade...',
              prefixIcon: Icon(Icons.search_rounded, color: textSecondary),
            ),
          ),
          const SizedBox(height: 16),

          // Filtros por tipo
          Row(
            children: [
              _FilterChip(
                label: 'Todos',
                isActive: _typeFilter == 'all',
                onTap: () => setState(() => _typeFilter = 'all'),
                bgSecondary: bgSecondary,
                borderColor: borderColor,
                textSecondary: textSecondary,
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Acampamentos',
                isActive: _typeFilter == 'camping',
                onTap: () => setState(() => _typeFilter = 'camping'),
                bgSecondary: bgSecondary,
                borderColor: borderColor,
                textSecondary: textSecondary,
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Eventos',
                isActive: _typeFilter == 'event',
                onTap: () => setState(() => _typeFilter = 'event'),
                bgSecondary: bgSecondary,
                borderColor: borderColor,
                textSecondary: textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 20),

          Text(
            'Atividades Disponíveis',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (_events.isEmpty)
            _EmptyState(
              message: 'Nenhuma atividade encontrada',
              actionLabel: 'SINCRONIZAR',
              onAction: _fetchData,
              borderColor: borderColor,
              textSecondary: textSecondary,
              textPrimary: textPrimary,
            )
          else if (filtered.isEmpty)
            _EmptyState(
              message: 'Nenhuma atividade corresponde à pesquisa.',
              borderColor: borderColor,
              textSecondary: textSecondary,
              textPrimary: textPrimary,
            )
          else
            ...filtered.map(
              (event) => EventCard(
                event: event,
                onTapDetails: () => _openEventDetails(event),
              ),
            ),
        ],
      ),
    );
  }

  // ABA DE INSCRIÇÕES
  Widget _buildSubscriptionsTab() {
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

    final filtered = _subscriptions.where((sub) {
      final eventName = sub['event']?['name']?.toString().toLowerCase() ?? '';
      return eventName.contains(_subSearchQuery.toLowerCase());
    }).toList();

    return RefreshIndicator(
      onRefresh: _fetchData,
      color: AppColors.brand,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            onChanged: (v) => setState(() => _subSearchQuery = v),
            decoration: InputDecoration(
              hintText: 'Pesquisar inscrições por nome do evento...',
              prefixIcon: Icon(Icons.search_rounded, color: textSecondary),
            ),
          ),
          const SizedBox(height: 20),
          if (_subscriptions.isEmpty)
            _EmptyState(
              message: 'Nenhuma inscrição encontrada',
              actionLabel: 'VER EVENTOS',
              onAction: () => _onTabSelected('events'),
              borderColor: borderColor,
              textSecondary: textSecondary,
              textPrimary: textPrimary,
            )
          else if (filtered.isEmpty)
            _EmptyState(
              message: 'Nenhuma inscrição corresponde à pesquisa.',
              borderColor: borderColor,
              textSecondary: textSecondary,
              textPrimary: textPrimary,
            )
          else
            ...filtered.map((sub) {
              final eventName = sub['event']?['name'] ?? 'Inscrição';
              final isApproved = sub['is_approved'] == true;
              final paidFee = sub['paid_the_fee'] == true;
              final wasSelected = sub['was_selected'] == true;
              final hasAnsweredForm = sub['has_answered_form'] == true;
              final subType = sub['subscription_type'] ?? '';

              // Status text
              String statusText;
              Color statusColor;
              if (isApproved) {
                statusText = 'Inscrição Confirmada';
                statusColor = const Color(0xFF22C55E);
              } else if (hasAnsweredForm) {
                statusText = 'Aguardando Avaliação';
                statusColor = Colors.orange;
              } else if (paidFee) {
                statusText = 'Aguardando Sorteio/Avaliação';
                statusColor = textSecondary;
              } else {
                statusText = 'Pagamento pendente';
                statusColor = textSecondary;
              }

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
                    // Badge de aprovação
                    if (isApproved)
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'INSCRIÇÃO APROVADA',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),

                    // Nome do evento
                    Text(
                      eventName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),

                    // Status
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Status: ',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          TextSpan(
                            text: statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Tipo: ',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          TextSpan(
                            text: subType,
                            style: TextStyle(color: textPrimary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Sorteado: ',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          TextSpan(
                            text: wasSelected ? 'Sim' : 'Não',
                            style: TextStyle(color: textPrimary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),

                    Divider(color: borderColor, height: 28),

                    // Ações baseadas no status
                    if (subType == 'Campista' &&
                        wasSelected &&
                        !hasAnsweredForm)
                      // Botão para prosseguir com o questionário
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.brand.withValues(alpha: 0.2),
                                offset: const Offset(0, 4),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedSubscriptionId = sub['id'];
                                _activeTab = 'questionnaire';
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'PROSSEGUIR COM A INSCRIÇÃO',
                              style: TextStyle(
                                fontSize: 11,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      )
                    else if (hasAnsweredForm && !isApproved)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'AGUARDANDO AVALIAÇÃO DOS CONSELHEIROS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: textSecondary,
                            letterSpacing: 1,
                          ),
                        ),
                      )
                    else if (isApproved)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: Color(0xFF22C55E),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'INSCRIÇÃO APROVADA PELOS CONSELHEIROS',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF22C55E),
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      )
                    // Remover botão de cancelar inscrição
                    else
                      const SizedBox.shrink(),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ABA DE PERFIL
  Widget _buildProfileTab() {
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

    String cpfFormatted = '';
    final cpf = (_userData['cpf'] ?? _userData['document'] ?? '')
        .toString()
        .replaceAll(RegExp(r'\D'), '');
    if (cpf.length == 11) {
      cpfFormatted =
          '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9)}';
    } else {
      cpfFormatted = cpf;
    }

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
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.brand,
                  child: Text(
                    (_userData['name'] ?? 'U')
                        .toString()
                        .substring(0, 1)
                        .toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Configurações de Perfil',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Edite suas informações pessoais e credenciais.',
                        style: TextStyle(fontSize: 13, color: textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _profileLabel('NOME COMPLETO'),
            const SizedBox(height: 6),
            TextField(controller: _profileNameController),
            const SizedBox(height: 16),
            _profileLabel('E-MAIL'),
            const SizedBox(height: 6),
            TextField(
              controller: _profileEmailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _profileLabel('TELEFONE / CELULAR'),
            const SizedBox(height: 6),
            TextField(
              controller: _profilePhoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [PhoneInputFormatter()],
            ),
            const SizedBox(height: 16),
            _profileLabel('DOCUMENTO (CPF)'),
            const SizedBox(height: 6),
            TextField(
              controller: TextEditingController(text: cpfFormatted),
              readOnly: true,
              decoration: InputDecoration(
                fillColor: borderColor.withValues(alpha: 0.3),
              ),
            ),
            Divider(color: borderColor, height: 40),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brand.withValues(alpha: 0.3),
                      offset: const Offset(0, 6),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _updateProfile,
                  child: const Text('SALVAR'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileLabel(String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
      ),
    );
  }
}

/// Chip de filtro por tipo de atividade
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color bgSecondary;
  final Color borderColor;
  final Color textSecondary;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.bgSecondary,
    required this.borderColor,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.brand : bgSecondary,
          borderRadius: BorderRadius.circular(12),
          border: isActive ? null : Border.all(color: borderColor),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.brand.withValues(alpha: 0.2),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isActive ? Colors.white : textSecondary,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color borderColor;
  final Color textSecondary;
  final Color textPrimary;

  const _EmptyState({
    required this.message,
    this.actionLabel,
    this.onAction,
    required this.borderColor,
    required this.textSecondary,
    required this.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        children: [
          Text(
            message.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: textSecondary,
              letterSpacing: 1.5,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: textPrimary,
                foregroundColor: Theme.of(context).scaffoldBackgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                textStyle: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
