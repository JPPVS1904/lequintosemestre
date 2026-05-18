class Event {
  final int id;
  final String name;
  final String eventableType;
  final String? place;
  final String? startDate;
  final int? durationDays;
  final int? totalVacancies;
  final String? image;
  final Map<String, dynamic>? eventable;

  Event({
    required this.id,
    required this.name,
    required this.eventableType,
    this.place,
    this.startDate,
    this.durationDays,
    this.totalVacancies,
    this.image,
    this.eventable,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Evento sem nome',
      eventableType: json['eventable_type'] ?? '',
      place: json['place'],
      startDate: json['start_date'],
      durationDays: json['duration_days'],
      totalVacancies: json['total_vacancies'],
      image: json['image'],
      eventable: json['eventable'] as Map<String, dynamic>?,
    );
  }

  bool get isFestival => eventableType.contains('Festival');

  String get typeLabel => isFestival ? 'Festival' : 'Acampamento';

  // Preço de inscrição baseado no tipo (camper_fee para Acampamento, ticket_price para Festival)
  double get fee {
    if (eventable == null) return 0;
    final raw = eventable!['camper_fee'] ?? eventable!['ticket_price'] ?? 0;
    return double.tryParse(raw.toString()) ?? 0;
  }

  // Data final calculada a partir de data inicial + duração
  DateTime? get endDate {
    if (startDate == null) return null;
    final start = DateTime.tryParse(startDate!);
    if (start == null) return null;
    return start.add(Duration(days: durationDays ?? 0));
  }

  // Verifica se uma data de inscrição está aberta (start <= now <= end)
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

  // Verifica se as inscrições para campistas estão abertas
  bool get isCamperRegistrationOpen {
    if (isFestival || eventable == null) return false;
    return _periodOpen(
      eventable!['camper_registration_start_date'],
      eventable!['camper_registration_end_date'],
    );
  }

  // Verifica se as inscrições para servos estão abertas
  bool get isServantRegistrationOpen {
    if (isFestival || eventable == null) return false;
    return _periodOpen(
      eventable!['servant_registration_start_date'],
      eventable!['servant_registration_end_date'],
    );
  }

  // Verifica se alguma inscrição está aberta (campista OU servo OU festival)
  bool get isRegistrationOpen {
    if (isFestival) {
      // Aberto quando: sale_start_date <= now < event start_date
      return _periodOpen(
        eventable?['sale_start_date'],
        startDate, // usa o start_date do evento como data de encerramento
      );
    }
    return isCamperRegistrationOpen || isServantRegistrationOpen;
  }

  // Tipo de inscrição disponível ('Campista', 'Servo', null)
  // Prioriza Campista se ambos estiverem abertos
  String? get availableSubscriptionType {
    if (isCamperRegistrationOpen) return 'Campista';
    if (isServantRegistrationOpen) return 'Servo';
    return null;
  }

  // Próxima data de abertura de inscrições (campista ou servo)
  DateTime? get nextRegistrationStartDate {
    final now = DateTime.now();

    if (isFestival) {
      if (eventable == null) return null;
      final saleStart = eventable!['sale_start_date'];
      if (saleStart == null) return null;
      final date = DateTime.tryParse(saleStart);
      if (date != null && now.isBefore(date)) return date;
      return null;
    } else {
      if (eventable == null) return null;

      final startFields = [
        'camper_registration_start_date',
        'servant_registration_start_date',
      ];

      DateTime? earliestFuture;

      for (final field in startFields) {
        final val = eventable![field];
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

  // Label de status das inscrições para exibição
  // Ex: "INSCRIÇÕES PARA CAMPISTA ABERTAS", "INSCRIÇÕES ABERTAS A PARTIR DE 01/01/2026"
  String get registrationStatusLabel {
    if (isFestival) {
      if (isRegistrationOpen) return 'INSCRIÇÕES ABERTAS';
      final next = nextRegistrationStartDate;
      if (next != null) {
        final d = '${next.day.toString().padLeft(2, '0')}/${next.month.toString().padLeft(2, '0')}/${next.year}';
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
      final d = '${next.day.toString().padLeft(2, '0')}/${next.month.toString().padLeft(2, '0')}/${next.year}';
      return 'INSCRIÇÕES ABERTAS A PARTIR DE $d';
    }
    return 'INSCRIÇÕES ENCERRADAS';
  }
}

