class Event {
  final int id;
  final String name;
  final String eventableType;

  Event({
    required this.id,
    required this.name,
    required this.eventableType,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Evento sem nome',
      eventableType: json['eventable_type'] ?? '',
    );
  }
  
  bool get isFestival => eventableType == 'App\\Models\\Festival';
}
