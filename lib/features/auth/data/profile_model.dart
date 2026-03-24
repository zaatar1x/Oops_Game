class Profile {
  final String id;
  final String? firstName;
  final String? lastName;
  final DateTime? birthDate;
  final int xp;
  final int level;
  final String rank;
  final double skillRating;
  final int gamesPlayed;
  final int streak;
  final DateTime createdAt;

  Profile({
    required this.id,
    this.firstName,
    this.lastName,
    this.birthDate,
    required this.xp,
    required this.level,
    required this.rank,
    required this.skillRating,
    required this.gamesPlayed,
    required this.streak,
    required this.createdAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'])
          : null,
      xp: json['xp'] ?? 0,
      level: json['level'] ?? 1,
      rank: json['rank'] ?? 'Bronze',
      skillRating: (json['skill_rating'] as num?)?.toDouble() ?? 1.0,
      gamesPlayed: json['games_played'] ?? 0,
      streak: json['streak'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}