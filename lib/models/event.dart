/// Event model matching the Laravel API response structure
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

  /// Event fee based on type (camper_fee for Camping, ticket_price for Festival)
  double get fee {
    if (eventable == null) return 0;
    final raw = eventable!['camper_fee'] ?? eventable!['ticket_price'] ?? 0;
    return double.tryParse(raw.toString()) ?? 0;
  }

  /// End date calculated from start_date + duration_days
  DateTime? get endDate {
    if (startDate == null) return null;
    final start = DateTime.tryParse(startDate!);
    if (start == null) return null;
    return start.add(Duration(days: durationDays ?? 0));
  }
}
