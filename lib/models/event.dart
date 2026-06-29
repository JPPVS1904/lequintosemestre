/// Representa uma Atividade/Evento no sistema (Acampamento, Retiro, Curso, etc).
/// Contém propriedades básicas como nome, local, datas, vagas e também encapsula a lógica
/// de extração de detalhes específicos do [activitable] (o polimorfismo do Laravel).
class Event {
  final int id;
  final String name;
  final String activitableType;
  final String? place;
  final String? startDate;
  final int? durationDays;
  final int? totalVacancies;
  final String? image;
  final int? year;
  final Map<String, dynamic>? activitable;
  final Map<String, dynamic>? category;

  Event({
    required this.id,
    required this.name,
    required this.activitableType,
    this.place,
    this.startDate,
    this.durationDays,
    this.totalVacancies,
    this.image,
    this.year,
    this.activitable,
    this.category,
  });

  /// Cria uma instância de [Event] a partir de um mapa de dados JSON recebido da API.
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Atividade sem nome',
      activitableType: json['activitable_type'] ?? '',
      place: json['place'],
      startDate: json['start_date'],
      durationDays: json['duration_days'],
      totalVacancies: json['total_vacancies'],
      image: json['image'],
      year: json['year'] is int
          ? json['year']
          : int.tryParse(json['year']?.toString() ?? ''),
      activitable: json['activitable'] as Map<String, dynamic>?,
      category: json['category'] as Map<String, dynamic>?,
    );
  }

  bool get isCamping => activitableType.contains('Camping');
  bool get isEvent => activitableType.contains('Event');

  String get typeLabel => isCamping ? 'Acampamento' : 'Evento';

  String? get categoryName => category?['name'];

  List<Map<String, dynamic>> get categorySectors {
    final sectors = category?['sectors'];
    if (sectors is List) {
      return sectors.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Preço de inscrição baseado no tipo
  double get fee {
    if (activitable == null) return 0;
    final raw = activitable!['camper_fee'] ?? activitable!['ticket_price'] ?? 0;
    return double.tryParse(raw.toString()) ?? 0;
  }

  // Data final calculada a partir de data inicial + duração
  DateTime? get endDate {
    if (startDate == null) return null;
    final start = DateTime.tryParse(startDate!);
    if (start == null) return null;
    return start.add(Duration(days: durationDays ?? 0));
  }

  // Verifica se um período de inscrição está aberto
  bool _periodOpen(String? startField, String? endField) {
    final now = DateTime.now();
    if (startField != null) {
      final start = DateTime.tryParse(startField);
      if (start != null && now.isBefore(start)) return false;
    }
    if (endField != null) {
      final end = DateTime.tryParse(endField);
      if (end != null) {
        final endOfDay = end.add(const Duration(days: 1));
        if (now.isAfter(endOfDay)) return false;
      }
    }
    return true;
  }

  // Inscrições para campistas abertas
  bool get isCamperRegistrationOpen {
    if (!isCamping || activitable == null) return false;
    return _periodOpen(
      activitable!['camper_registration_start_date'],
      activitable!['camper_registration_end_date'],
    );
  }

  // Inscrições para servos abertas
  bool get isServantRegistrationOpen {
    if (!isCamping || activitable == null) return false;
    return _periodOpen(
      activitable!['servant_registration_start_date'],
      activitable!['servant_registration_end_date'],
    );
  }

  // Alguma inscrição aberta
  bool get isRegistrationOpen {
    if (isEvent) {
      return _periodOpen(activitable?['sale_start_date'], startDate);
    }
    return isCamperRegistrationOpen || isServantRegistrationOpen;
  }

  // Tipo de inscrição disponível
  String? get availableSubscriptionType {
    if (isCamperRegistrationOpen) return 'Campista';
    if (isServantRegistrationOpen) return 'Servo';
    return null;
  }

  // Próxima data de abertura
  DateTime? get nextRegistrationStartDate {
    final now = DateTime.now();

    if (isEvent) {
      if (activitable == null) return null;
      final saleStart = activitable!['sale_start_date'];
      if (saleStart == null) return null;
      final date = DateTime.tryParse(saleStart);
      if (date != null && now.isBefore(date)) return date;
      return null;
    } else {
      if (activitable == null) return null;
      final startFields = [
        'camper_registration_start_date',
        'servant_registration_start_date',
      ];
      DateTime? earliestFuture;
      for (final field in startFields) {
        final val = activitable![field];
        if (val != null) {
          final date = DateTime.tryParse(val);
          if (date != null && now.isBefore(date)) {
            if (earliestFuture == null || date.isBefore(earliestFuture)) {
              earliestFuture = date;
            }
          }
        }
      }
      return earliestFuture;
    }
  }

  // Faixa de idade (acampamentos)
  int? get minimalAge => activitable?['minimal_age'];
  int? get maximalAge => activitable?['maximal_age'];

  // Label de status das inscrições
  String get registrationStatusLabel {
    if (isEvent) {
      if (isRegistrationOpen) return 'INSCRIÇÕES ABERTAS';
      final next = nextRegistrationStartDate;
      if (next != null) {
        final d =
            '${next.day.toString().padLeft(2, '0')}/${next.month.toString().padLeft(2, '0')}/${next.year}';
        return 'INSCRIÇÕES ABERTAS A PARTIR DE $d';
      }
      return 'INSCRIÇÕES ENCERRADAS';
    }

    if (isCamperRegistrationOpen && isServantRegistrationOpen) {
      return 'INSCRIÇÕES ABERTAS';
    }
    if (isCamperRegistrationOpen) return 'INSCRIÇÕES PARA CAMPISTA ABERTAS';
    if (isServantRegistrationOpen) return 'INSCRIÇÕES PARA SERVO ABERTAS';

    final next = nextRegistrationStartDate;
    if (next != null) {
      final d =
          '${next.day.toString().padLeft(2, '0')}/${next.month.toString().padLeft(2, '0')}/${next.year}';
      return 'INSCRIÇÕES ABERTAS A PARTIR DE $d';
    }
    return 'INSCRIÇÕES ENCERRADAS';
  }
}
