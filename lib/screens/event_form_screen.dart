import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/event_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_modal.dart';

/// Event creation form matching EventForm.svelte
/// Supports both Acampamento (Camping) and Festival types.
class EventFormScreen extends StatefulWidget {
  final VoidCallback onSaveSuccess;
  final VoidCallback onCancel;

  const EventFormScreen({
    super.key,
    required this.onSaveSuccess,
    required this.onCancel,
  });

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _eventService = EventService();
  bool _loading = false;
  String _eventType = 'App\\Models\\Camping';

  // ── General fields ──
  final _nameCtrl = TextEditingController();
  final _placeCtrl = TextEditingController();
  final _yearCtrl = TextEditingController(text: DateTime.now().year.toString());
  final _durationCtrl = TextEditingController(text: '1');
  final _imageCtrl = TextEditingController();
  DateTime? _startDate;

  // ── Camping-specific fields ──
  final _noticeCtrl = TextEditingController();
  final _termCtrl = TextEditingController();
  final _camperFeeCtrl = TextEditingController(text: '0');
  final _servantFeeCtrl = TextEditingController(text: '0');
  final _minAgeCtrl = TextEditingController(text: '0');
  final _maxAgeCtrl = TextEditingController(text: '99');
  final _raffleManCtrl = TextEditingController(text: '0');
  final _raffleWomanCtrl = TextEditingController(text: '0');
  final _raffleCoupleCtrl = TextEditingController(text: '0');
  final _camperPaymentLinkCtrl = TextEditingController();
  final _servantPaymentLinkCtrl = TextEditingController();

  // Camping date fields
  DateTime? _raffleCamperSubStart;
  DateTime? _raffleCamperSubEnd;
  DateTime? _raffleCamperDate;
  DateTime? _raffleServantSubStart;
  DateTime? _raffleServantSubEnd;
  DateTime? _raffleServantDate;
  DateTime? _camperRegStart;
  DateTime? _camperRegEnd;
  DateTime? _camperPaymentDate;
  DateTime? _servantRegStart;
  DateTime? _servantRegEnd;
  DateTime? _servantPaymentDate;

  // ── Festival-specific fields ──
  final _festMinAgeCtrl = TextEditingController(text: '0');
  final _ticketPriceCtrl = TextEditingController(text: '0');
  final _festPaymentLinkCtrl = TextEditingController();
  DateTime? _saleStartDate;
  bool _isPaidFestival = false;

  bool get _isCamping => _eventType.contains('Camping');

  String _fmtDate(DateTime? d) =>
      d != null ? DateFormat('dd/MM/yyyy').format(d) : 'Selecionar';

  String _isoDate(DateTime? d) =>
      d != null ? DateFormat('yyyy-MM-dd').format(d) : '';

  Future<DateTime?> _pickDate({DateTime? initial}) async {
    return showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(primary: AppColors.brand),
        ),
        child: child!,
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_nameCtrl.text.isEmpty || _placeCtrl.text.isEmpty || _startDate == null) {
      showAppModal(context, type: 'error', message: 'Preencha os campos obrigatórios: Nome, Local e Data de Início.');
      return;
    }

    setState(() => _loading = true);

    try {
      // 1. Create eventable (Camping or Festival)
      Map<String, dynamic> eventableResult;

      if (_isCamping) {
        final man = int.tryParse(_raffleManCtrl.text) ?? 0;
        final woman = int.tryParse(_raffleWomanCtrl.text) ?? 0;
        final couple = int.tryParse(_raffleCoupleCtrl.text) ?? 0;
        final totalVacancies = man + woman + couple * 2;

        final campingPayload = {
          'notice': _noticeCtrl.text,
          'term': _termCtrl.text,
          'camper_fee': double.tryParse(_camperFeeCtrl.text) ?? 0,
          'servant_fee': double.tryParse(_servantFeeCtrl.text) ?? 0,
          'minimal_age': int.tryParse(_minAgeCtrl.text) ?? 0,
          'maximal_age': int.tryParse(_maxAgeCtrl.text) ?? 99,
          'raffle_man_vacancies': man,
          'raffle_woman_vacancies': woman,
          'raffle_couple_vacancies': couple,
          'raffle_total_vacancies': totalVacancies,
          'raffle_camper_subscription_start_date': _isoDate(_raffleCamperSubStart),
          'raffle_camper_subscription_end_date': _isoDate(_raffleCamperSubEnd),
          'raffle_camper_date': _isoDate(_raffleCamperDate),
          'raffle_servant_subscription_start_date': _isoDate(_raffleServantSubStart),
          'raffle_servant_subscription_end_date': _isoDate(_raffleServantSubEnd),
          'raffle_servant_date': _isoDate(_raffleServantDate),
          'camper_registration_start_date': _isoDate(_camperRegStart),
          'camper_registration_end_date': _isoDate(_camperRegEnd),
          'camper_payment_link': _camperPaymentLinkCtrl.text,
          'camper_payment_date': _isoDate(_camperPaymentDate),
          'servant_registration_start_date': _isoDate(_servantRegStart),
          'servant_registration_end_date': _isoDate(_servantRegEnd),
          'servant_payment_link': _servantPaymentLinkCtrl.text,
          'servant_payment_date': _isoDate(_servantPaymentDate),
        };

        eventableResult = await _eventService.createCamping(campingPayload);
      } else {
        final festivalPayload = {
          'minimal_age': int.tryParse(_festMinAgeCtrl.text) ?? 0,
          'is_paid_festival': _isPaidFestival,
          'ticket_price': double.tryParse(_ticketPriceCtrl.text) ?? 0,
          'sale_start_date': _isoDate(_saleStartDate),
          'payment_link': _festPaymentLinkCtrl.text,
        };
        eventableResult = await _eventService.createFestival(festivalPayload);
      }

      if (eventableResult['success'] != true) {
        if (!mounted) return;
        setState(() => _loading = false);
        showAppModal(context, type: 'error', message: eventableResult['message'] ?? 'Erro ao criar detalhes.');
        return;
      }

      final eventableId = eventableResult['data']['id'];

      // 2. Create the Event
      final man = int.tryParse(_raffleManCtrl.text) ?? 0;
      final woman = int.tryParse(_raffleWomanCtrl.text) ?? 0;
      final couple = int.tryParse(_raffleCoupleCtrl.text) ?? 0;

      final eventPayload = {
        'name': _nameCtrl.text,
        'place': _placeCtrl.text,
        'year': int.tryParse(_yearCtrl.text) ?? DateTime.now().year,
        'start_date': '${_isoDate(_startDate)} 00:00:00',
        'duration_days': int.tryParse(_durationCtrl.text) ?? 1,
        'total_vacancies': _isCamping ? (man + woman + couple * 2) : 999999,
        'image': _imageCtrl.text,
        'eventable_id': eventableId,
        'eventable_type': _eventType,
      };

      final eventResult = await _eventService.createEvent(eventPayload);

      if (!mounted) return;
      setState(() => _loading = false);

      if (eventResult['success'] == true) {
        await showAppModal(context, type: 'success', message: 'Evento criado com sucesso!');
        widget.onSaveSuccess();
      } else {
        showAppModal(context, type: 'error', message: eventResult['message'] ?? 'Erro ao criar evento.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      showAppModal(context, type: 'error', message: 'Erro inesperado: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final bgSecondary = isDark ? AppColors.darkBgSecondary : AppColors.lightBgSecondary;
    final borderColor = isDark ? AppColors.darkBorderUi : AppColors.lightBorderUi;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Back button ──
          TextButton.icon(
            onPressed: widget.onCancel,
            icon: Icon(Icons.arrow_back_ios_rounded, size: 16, color: textSecondary),
            label: Text('VOLTAR', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1, color: textSecondary)),
          ),
          const SizedBox(height: 8),

          // Main container
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
                // ═══ SECTION 1: Tipo de Evento ═══
                _sectionTitle('1. TIPO DE EVENTO'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _typeChip('Acampamento', 'App\\Models\\Camping', textPrimary, borderColor)),
                    const SizedBox(width: 12),
                    Expanded(child: _typeChip('Festival', 'App\\Models\\Festival', textPrimary, borderColor)),
                  ],
                ),
                const SizedBox(height: 28),

                // ═══ SECTION 2: Informações Gerais ═══
                _sectionTitle('2. INFORMAÇÕES GERAIS'),
                const SizedBox(height: 12),
                _fieldLabel('NOME DO EVENTO *'),
                const SizedBox(height: 6),
                TextField(controller: _nameCtrl),
                const SizedBox(height: 12),
                _fieldLabel('LOCAL *'),
                const SizedBox(height: 6),
                TextField(controller: _placeCtrl),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _fieldLabel('ANO *'),
                    const SizedBox(height: 6),
                    TextField(controller: _yearCtrl, keyboardType: TextInputType.number),
                  ])),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _fieldLabel('DURAÇÃO (DIAS) *'),
                    const SizedBox(height: 6),
                    TextField(controller: _durationCtrl, keyboardType: TextInputType.number),
                  ])),
                ]),
                const SizedBox(height: 12),
                _fieldLabel('DATA DE INÍCIO *'),
                const SizedBox(height: 6),
                _dateTile(_startDate, (d) => setState(() => _startDate = d), borderColor, textPrimary, textSecondary),
                const SizedBox(height: 12),
                _fieldLabel('URL DA IMAGEM'),
                const SizedBox(height: 6),
                TextField(controller: _imageCtrl, decoration: const InputDecoration(hintText: 'Link ou path da Imagem')),
                const SizedBox(height: 28),

                // ═══ SECTION 3: Configurações Específicas ═══
                _sectionTitle('3. CONFIGURAÇÕES ESPECÍFICAS'),
                const SizedBox(height: 12),

                if (_isCamping) _buildCampingFields(textPrimary, textSecondary, borderColor)
                else _buildFestivalFields(textPrimary, textSecondary, borderColor),

                // ═══ Action buttons ═══
                Divider(color: borderColor, height: 40),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.onCancel,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: borderColor),
                        ),
                        child: Text('CANCELAR', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 1, color: textSecondary)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: AppColors.brand.withValues(alpha: 0.2), offset: const Offset(0, 6), blurRadius: 16)],
                        ),
                        child: ElevatedButton(
                          onPressed: _loading ? null : _handleSubmit,
                          child: _loading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                              : const Text('SALVAR EVENTO'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Camping-specific fields ──
  Widget _buildCampingFields(Color textPrimary, Color textSecondary, Color borderColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: borderColor)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _fieldLabel('LINK DO EDITAL'), const SizedBox(height: 6), TextField(controller: _noticeCtrl),
          ])),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _fieldLabel('LINK DOS TERMOS'), const SizedBox(height: 6), TextField(controller: _termCtrl),
          ])),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _numField('IDADE MÍNIMA', _minAgeCtrl)),
          const SizedBox(width: 12),
          Expanded(child: _numField('IDADE MÁXIMA', _maxAgeCtrl)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _numField('TAXA CAMPISTA (R\$)', _camperFeeCtrl)),
          const SizedBox(width: 12),
          Expanded(child: _numField('TAXA SERVO (R\$)', _servantFeeCtrl)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _numField('VAGAS HOMEM', _raffleManCtrl)),
          const SizedBox(width: 8),
          Expanded(child: _numField('VAGAS MULHER', _raffleWomanCtrl)),
          const SizedBox(width: 8),
          Expanded(child: _numField('VAGAS CASAL', _raffleCoupleCtrl)),
        ]),

        // Datas do Sorteio
        Padding(padding: const EdgeInsets.only(top: 20, bottom: 8), child: _sectionTitle('DATAS DO SORTEIO')),
        _dateRow('INÍCIO INSC. CAMPISTA', _raffleCamperSubStart, (d) => setState(() => _raffleCamperSubStart = d), borderColor, textPrimary, textSecondary),
        _dateRow('FIM INSC. CAMPISTA', _raffleCamperSubEnd, (d) => setState(() => _raffleCamperSubEnd = d), borderColor, textPrimary, textSecondary),
        _dateRow('DATA SORTEIO CAMPISTA', _raffleCamperDate, (d) => setState(() => _raffleCamperDate = d), borderColor, textPrimary, textSecondary),
        _dateRow('INÍCIO INSC. SERVO', _raffleServantSubStart, (d) => setState(() => _raffleServantSubStart = d), borderColor, textPrimary, textSecondary),
        _dateRow('FIM INSC. SERVO', _raffleServantSubEnd, (d) => setState(() => _raffleServantSubEnd = d), borderColor, textPrimary, textSecondary),
        _dateRow('DATA SORTEIO SERVO', _raffleServantDate, (d) => setState(() => _raffleServantDate = d), borderColor, textPrimary, textSecondary),

        // Datas de Registro
        Padding(padding: const EdgeInsets.only(top: 20, bottom: 8), child: _sectionTitle('DATAS DE REGISTRO')),
        _dateRow('INÍCIO REG. CAMPISTA', _camperRegStart, (d) => setState(() => _camperRegStart = d), borderColor, textPrimary, textSecondary),
        _dateRow('FIM REG. CAMPISTA', _camperRegEnd, (d) => setState(() => _camperRegEnd = d), borderColor, textPrimary, textSecondary),
        _fieldLabel('LINK PGTO CAMPISTA'), const SizedBox(height: 6), TextField(controller: _camperPaymentLinkCtrl), const SizedBox(height: 8),
        _dateRow('DATA PGTO CAMPISTA', _camperPaymentDate, (d) => setState(() => _camperPaymentDate = d), borderColor, textPrimary, textSecondary),
        _dateRow('INÍCIO REG. SERVO', _servantRegStart, (d) => setState(() => _servantRegStart = d), borderColor, textPrimary, textSecondary),
        _dateRow('FIM REG. SERVO', _servantRegEnd, (d) => setState(() => _servantRegEnd = d), borderColor, textPrimary, textSecondary),
        _fieldLabel('LINK PGTO SERVO'), const SizedBox(height: 6), TextField(controller: _servantPaymentLinkCtrl), const SizedBox(height: 8),
        _dateRow('DATA PGTO SERVO', _servantPaymentDate, (d) => setState(() => _servantPaymentDate = d), borderColor, textPrimary, textSecondary),
      ]),
    );
  }

  // ── Festival-specific fields ──
  Widget _buildFestivalFields(Color textPrimary, Color textSecondary, Color borderColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: borderColor)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: _numField('IDADE MÍNIMA', _festMinAgeCtrl)),
          const SizedBox(width: 12),
          Expanded(child: _numField('PREÇO DO INGRESSO', _ticketPriceCtrl)),
        ]),
        const SizedBox(height: 12),
        _fieldLabel('INÍCIO DAS VENDAS'),
        const SizedBox(height: 6),
        _dateTile(_saleStartDate, (d) => setState(() => _saleStartDate = d), borderColor, textPrimary, textSecondary),
        const SizedBox(height: 12),
        _fieldLabel('LINK DE PAGAMENTO'),
        const SizedBox(height: 6),
        TextField(controller: _festPaymentLinkCtrl),
        const SizedBox(height: 12),
        Row(children: [
          Checkbox(value: _isPaidFestival, onChanged: (v) => setState(() => _isPaidFestival = v ?? false)),
          Text('Festival Pago', style: TextStyle(fontWeight: FontWeight.w700, color: textPrimary, fontSize: 14)),
        ]),
      ]),
    );
  }

  // ── Helper widgets ──
  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.brand, letterSpacing: 2),
      );

  Widget _fieldLabel(String text) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
      );

  Widget _numField(String label, TextEditingController ctrl) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_fieldLabel(label), const SizedBox(height: 6), TextField(controller: ctrl, keyboardType: const TextInputType.numberWithOptions(decimal: true))],
      );

  Widget _typeChip(String label, String value, Color textPrimary, Color borderColor) {
    final isSelected = _eventType == value;
    return GestureDetector(
      onTap: () => setState(() => _eventType = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.brand : borderColor, width: 2),
          color: isSelected ? AppColors.brand.withValues(alpha: 0.05) : Colors.transparent,
        ),
        child: Center(child: Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: textPrimary))),
      ),
    );
  }

  Widget _dateTile(DateTime? date, Function(DateTime) onPick, Color borderColor, Color textPrimary, Color textSecondary) {
    return GestureDetector(
      onTap: () async {
        final d = await _pickDate(initial: date);
        if (d != null) onPick(d);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(border: Border.all(color: borderColor), borderRadius: BorderRadius.circular(16)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(_fmtDate(date), style: TextStyle(color: date != null ? AppColors.brand : textSecondary, fontWeight: FontWeight.w700)),
          Icon(Icons.calendar_today_rounded, color: textSecondary, size: 18),
        ]),
      ),
    );
  }

  Widget _dateRow(String label, DateTime? date, Function(DateTime) onPick, Color borderColor, Color textPrimary, Color textSecondary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _fieldLabel(label),
        const SizedBox(height: 4),
        _dateTile(date, onPick, borderColor, textPrimary, textSecondary),
      ]),
    );
  }
}
