class Room {
  final String id;
  final String rank;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;

  Room({
    required this.id,
    required this.rank,
    required this.startDate,
    this.endDate,
    required this.isActive,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      rank: json['rank'],
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      isActive: json['is_active'] ?? true,
    );
  }
}
