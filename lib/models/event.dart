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
}
