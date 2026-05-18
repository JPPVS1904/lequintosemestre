import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart' show themeNotifier;
import '../models/event.dart';
import '../services/event_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_modal.dart';
import '../widgets/event_card.dart';
import 'event_details_view.dart';
import 'event_form_screen.dart';

// Tela do Painel
// Abas: events, subscriptions, profile, event_details, event_form (admin)
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
  bool _isAdmin = false;
  Map<String, dynamic> _userData = {};
  List<Event> _events = [];
  List<Map<String, dynamic>> _subscriptions = [];
  Event? _selectedEvent;

  String _eventSearchQuery = '';
  String _subSearchQuery = '';

  final _profileNameController = TextEditingController();
  final _profileEmailController = TextEditingController();
  final _profilePhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataStr = prefs.getString('user_data');
    if (userDataStr != null) {
      _userData = jsonDecode(userDataStr);
      _isAdmin = _userData['is_counselor'] == true ||
          _userData['is_admin'] == true ||
          _userData['role'] == 'admin';
      _profileNameController.text = _userData['name'] ?? '';
      _profileEmailController.text = _userData['email'] ?? '';
      _profilePhoneController.text = _userData['phone']?.toString() ?? '';
    }
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    if (_activeTab == 'events') {
      _events = await _eventService.fetchEvents(isAdmin: _isAdmin);
    } else if (_activeTab == 'subscriptions') {
      final rawId = _userData['id'];
      if (rawId != null) {
        final userId = rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0;
        _subscriptions = await _eventService.fetchSubscriptions(userId);
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _onTabSelected(String tab) {
    setState(() {
      _activeTab = tab;
      _selectedEvent = null;
    });
    if (tab != 'event_form') _fetchData();
  }

  void _openEventDetails(Event event) {
    setState(() {
      _selectedEvent = event;
      _activeTab = 'event_details';
    });
  }

  Future<void> _requestSubscription(int eventId) async {
    final confirmed = await showAppModal(context, type: 'confirm',
      message: 'Ao confirmar, você será redirecionado para suas inscrições. Deseja continuar?');
    if (confirmed != true) return;
    final rawId = _userData['id'];
    final userId = rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0;
    final result = await _eventService.subscribe(eventId, userId);
    if (!mounted) return;
    if (result['success'] == true) {
      await showAppModal(context, type: 'success', message: 'Inscrição realizada com sucesso!');
      _onTabSelected('subscriptions');
    } else {
      showAppModal(context, type: 'error', message: result['message'] ?? 'Erro ao se inscrever.');
    }
  }

  Future<void> _requestCancelSubscription(int subscriptionId) async {
    final confirmed = await showAppModal(context, type: 'confirm',
      message: 'Tem certeza que deseja cancelar esta inscrição? Esta ação não pode ser desfeita.');
    if (confirmed != true) return;
    final result = await _eventService.cancelSubscription(subscriptionId);
    if (!mounted) return;
    if (result['success'] == true) {
      await showAppModal(context, type: 'success', message: 'Inscrição cancelada com sucesso!');
      _fetchData();
    } else {
      showAppModal(context, type: 'error', message: result['message'] ?? 'Erro ao cancelar.');
    }
  }

  Future<void> _updateProfile() async {
    final confirmed = await showAppModal(context, type: 'confirm',
      message: 'Deseja realmente salvar as alterações no seu perfil?');
    if (confirmed != true) return;
    final payload = {
      'name': _profileNameController.text,
      'email': _profileEmailController.text,
      'phone': _profilePhoneController.text.replaceAll(RegExp(r'\D'), ''),
    };
    final cpf = _userData['cpf'] ?? _userData['document'];
    if (cpf != null) payload['cpf'] = cpf.toString().replaceAll(RegExp(r'\D'), '');
    final result = await _eventService.updateProfile(_userData['id'], payload);
    if (!mounted) return;
    if (result['success'] == true) {
      if (result['data'] != null) {
        _userData = {..._userData, ...Map<String, dynamic>.from(result['data'])};
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(_userData));
      }
      if (!mounted) return;
      showAppModal(context, type: 'success', message: 'Perfil atualizado com sucesso!');
    } else {
      if (!mounted) return;
      showAppModal(context, type: 'error', message: result['message'] ?? 'Erro ao atualizar.');
    }
  }

  String get _appBarTitle {
    switch (_activeTab) {
      case 'events': return 'Painel Geral';
      case 'subscriptions': return 'Minhas Inscrições';
      case 'profile': return 'Perfil';
      case 'event_details': return _selectedEvent?.name ?? 'Detalhes';
      case 'event_form': return 'Criar Evento';
      default: return 'Painel';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final bgPrimary = isDark ? AppColors.darkBgPrimary : AppColors.lightBgPrimary;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bgPrimary,
      drawer: AppDrawer(
        activeTab: _activeTab,
        isAdmin: _isAdmin,
        onTabSelected: _onTabSelected,
        onAddEvent: () => _onTabSelected('event_form'),
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu_rounded, color: textPrimary),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(_appBarTitle),
        actions: [
          IconButton(
            onPressed: themeNotifier.toggle,
            icon: Icon(isDark ? Icons.wb_sunny_rounded : Icons.dark_mode_rounded, color: textPrimary, size: 20),
          ),
          GestureDetector(
            onTap: () => _onTabSelected('profile'),
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.brand,
                child: Text(
                  (_userData['name'] ?? 'U').toString().substring(0, 1).toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _activeTab == 'event_form'
          ? EventFormScreen(
              onSaveSuccess: () => _onTabSelected('events'),
              onCancel: () => _onTabSelected('events'),
            )
          : _isLoading
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const CircularProgressIndicator(color: AppColors.brand),
                    const SizedBox(height: 16),
                    Text('Buscando dados...', style: TextStyle(color: textPrimary.withValues(alpha: 0.6))),
                  ]),
                )
              : _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_activeTab) {
      case 'events': return _buildEventsTab();
      case 'subscriptions': return _buildSubscriptionsTab();
      case 'profile': return _buildProfileTab();
      case 'event_details':
        if (_selectedEvent != null) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: EventDetailsView(
              event: _selectedEvent!,
              onBack: () => _onTabSelected('events'),
              onSubscribe: () => _requestSubscription(_selectedEvent!.id),
            ),
          );
        }
        return const SizedBox.shrink();
      default: return const SizedBox.shrink();
    }
  }

  // ABA DE EVENTOS
  Widget _buildEventsTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.darkBorderUi : AppColors.lightBorderUi;

    final filtered = _events.where((e) {
      final matchesSearch = e.name.toLowerCase().contains(_eventSearchQuery.toLowerCase());
      if (!matchesSearch) return false;
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
          Text('Bem-vindo de volta,', style: TextStyle(fontSize: 14, color: textSecondary)),
          Text(_userData['name'] ?? 'Usuário', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: textPrimary)),
          const SizedBox(height: 20),
          TextField(
            onChanged: (v) => setState(() => _eventSearchQuery = v),
            decoration: InputDecoration(hintText: 'Pesquisar por nome do evento...', prefixIcon: Icon(Icons.search_rounded, color: textSecondary)),
          ),
          const SizedBox(height: 20),
          Text('Eventos Disponíveis', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textPrimary)),
          const SizedBox(height: 16),
          if (_events.isEmpty)
            _EmptyState(message: 'Nenhum evento encontrado', actionLabel: 'SINCRONIZAR', onAction: _fetchData, borderColor: borderColor, textSecondary: textSecondary, textPrimary: textPrimary)
          else if (filtered.isEmpty)
            _EmptyState(message: 'Nenhum evento corresponde à pesquisa.', borderColor: borderColor, textSecondary: textSecondary, textPrimary: textPrimary)
          else
            ...filtered.map((event) => EventCard(event: event, onTapDetails: () => _openEventDetails(event))),
        ],
      ),
    );
  }

  // ABA DE INSCRIÇÕES
  Widget _buildSubscriptionsTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final bgSecondary = isDark ? AppColors.darkBgSecondary : AppColors.lightBgSecondary;
    final borderColor = isDark ? AppColors.darkBorderUi : AppColors.lightBorderUi;

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
            decoration: InputDecoration(hintText: 'Pesquisar inscrições por nome do evento...', prefixIcon: Icon(Icons.search_rounded, color: textSecondary)),
          ),
          const SizedBox(height: 20),
          if (_subscriptions.isEmpty)
            _EmptyState(message: 'Nenhuma inscrição encontrada', actionLabel: 'VER EVENTOS', onAction: () => _onTabSelected('events'), borderColor: borderColor, textSecondary: textSecondary, textPrimary: textPrimary)
          else if (filtered.isEmpty)
            _EmptyState(message: 'Nenhuma inscrição corresponde à pesquisa.', borderColor: borderColor, textSecondary: textSecondary, textPrimary: textPrimary)
          else
            ...filtered.map((sub) {
              final eventName = sub['event']?['name'] ?? 'Inscrição';
              final eventType = sub['event']?['eventable_type'] ?? '';
              final isFestival = eventType == 'App\\Models\\Festival';
              final paidFee = sub['paid_the_fee'] == true;
              final wasSelected = sub['was_selected'] == true;
              final subType = sub['subscription_type'] ?? '';

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: bgSecondary, borderRadius: BorderRadius.circular(28), border: Border.all(color: borderColor)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(eventName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: AppColors.brand.withValues(alpha: 0.1), border: Border.all(color: AppColors.brand.withValues(alpha: 0.2)), borderRadius: BorderRadius.circular(20)),
                      child: Text(isFestival ? 'FESTIVAL' : 'ACAMPAMENTO', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.brand, letterSpacing: 1.5)),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Text.rich(TextSpan(children: [
                    TextSpan(text: 'Status: ', style: TextStyle(fontWeight: FontWeight.w700, color: textSecondary, fontSize: 13)),
                    TextSpan(text: paidFee ? 'Confirmado' : 'Pagamento pendente', style: TextStyle(color: textPrimary, fontSize: 13)),
                  ])),
                  const SizedBox(height: 4),
                  Text.rich(TextSpan(children: [
                    TextSpan(text: 'Tipo: ', style: TextStyle(fontWeight: FontWeight.w700, color: textSecondary, fontSize: 13)),
                    TextSpan(text: subType, style: TextStyle(color: textPrimary, fontSize: 13)),
                  ])),
                  const SizedBox(height: 4),
                  Text.rich(TextSpan(children: [
                    TextSpan(text: 'Sorteado: ', style: TextStyle(fontWeight: FontWeight.w700, color: textSecondary, fontSize: 13)),
                    TextSpan(text: wasSelected ? 'Sim' : 'Não', style: TextStyle(color: textPrimary, fontSize: 13)),
                  ])),
                  Divider(color: borderColor, height: 28),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _requestCancelSubscription(sub['id']),
                      style: TextButton.styleFrom(foregroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), backgroundColor: Colors.redAccent.withValues(alpha: 0.1)),
                      child: const Text('CANCELAR INSCRIÇÃO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
                    ),
                  ),
                ]),
              );
            }),
        ],
      ),
    );
  }

  // ABA DE PERFIL
  Widget _buildProfileTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final bgSecondary = isDark ? AppColors.darkBgSecondary : AppColors.lightBgSecondary;
    final borderColor = isDark ? AppColors.darkBorderUi : AppColors.lightBorderUi;

    String cpfFormatted = '';
    final cpf = (_userData['cpf'] ?? _userData['document'] ?? '').toString().replaceAll(RegExp(r'\D'), '');
    if (cpf.length == 11) {
      cpfFormatted = '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9)}';
    } else {
      cpfFormatted = cpf;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: bgSecondary, borderRadius: BorderRadius.circular(28), border: Border.all(color: borderColor)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(radius: 32, backgroundColor: AppColors.brand, child: Text((_userData['name'] ?? 'U').toString().substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24))),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Configurações de Perfil', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textPrimary)),
              const SizedBox(height: 4),
              Text('Edite suas informações pessoais e credenciais.', style: TextStyle(fontSize: 13, color: textSecondary)),
            ])),
          ]),
          const SizedBox(height: 28),
          _profileLabel('NOME COMPLETO'), const SizedBox(height: 6), TextField(controller: _profileNameController),
          const SizedBox(height: 16),
          _profileLabel('E-MAIL'), const SizedBox(height: 6), TextField(controller: _profileEmailController, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),
          _profileLabel('TELEFONE / CELULAR'), const SizedBox(height: 6), TextField(controller: _profilePhoneController, keyboardType: TextInputType.phone),
          const SizedBox(height: 16),
          _profileLabel('DOCUMENTO (CPF)'), const SizedBox(height: 6),
          TextField(controller: TextEditingController(text: cpfFormatted), readOnly: true, decoration: InputDecoration(fillColor: borderColor.withValues(alpha: 0.3))),
          Divider(color: borderColor, height: 40),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: AppColors.brand.withValues(alpha: 0.3), offset: const Offset(0, 6), blurRadius: 16)]),
              child: ElevatedButton(onPressed: _updateProfile, child: const Text('SALVAR ALTERAÇÕES')),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _profileLabel(String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.only(left: 4), child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary))));
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color borderColor;
  final Color textSecondary;
  final Color textPrimary;

  const _EmptyState({required this.message, this.actionLabel, this.onAction, required this.borderColor, required this.textSecondary, required this.textPrimary});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), border: Border.all(color: borderColor, width: 2)),
      child: Column(children: [
        Text(message.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: textSecondary, letterSpacing: 1.5)),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(backgroundColor: textPrimary, foregroundColor: Theme.of(context).scaffoldBackgroundColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
            child: Text(actionLabel!),
          ),
        ],
      ]),
    );
  }
}
