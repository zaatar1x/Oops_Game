class RoomMember {
  final String id;
  final String roomId;
  final String userId;
  final int rp;
  final int gamesPlayed;
  final String? firstName;
  final String? lastName;
  final String? rank;

  RoomMember({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.rp,
    required this.gamesPlayed,
    this.firstName,
    this.lastName,
    this.rank,
  });

  factory RoomMember.fromJson(Map<String, dynamic> json) {
    return RoomMember(
      id: json['id'],
      roomId: json['room_id'],
      userId: json['user_id'],
      rp: json['rp'] ?? 0,
      gamesPlayed: json['games_played'] ?? 0,
      firstName: json['first_name'],
      lastName: json['last_name'],
      rank: json['rank'],
    );
  }

  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    }
    return 'Player';
  }
}
