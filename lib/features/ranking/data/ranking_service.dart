import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/room_model.dart';
import '../models/room_member_model.dart';

class RankingService {
  final supabase = Supabase.instance.client;

  // Get active room by rank
  Future<Room> getActiveRoomByRank(String rank) async {
    final response = await supabase
        .from('rooms')
        .select()
        .eq('rank', rank)
        .eq('is_active', true)
        .single();

    return Room.fromJson(response);
  }

  // Get room by rank (for backward compatibility)
  Future<Map<String, dynamic>> getRoomByRank(String rank) async {
    final rooms = await supabase
        .from('rooms')
        .select()
        .eq('rank', rank);

    if (rooms.isEmpty) {
      throw Exception("No room found for rank: $rank");
    }

    return rooms.first;
  }

  // Join room
  Future<void> joinRoom({
    required String userId,
    required String rank,
  }) async {
    final room = await getRoomByRank(rank);
    final roomId = room['id'];

    final existing = await supabase
        .from('room_members')
        .select()
        .eq('user_id', userId)
        .eq('room_id', roomId);

    if (existing.isEmpty) {
      await supabase.from('room_members').insert({
        'room_id': roomId,
        'user_id': userId,
        'rp': 0,
        'games_played': 0,
      });
    }
  }

  // Update RP after game
  Future<void> updateRP({
    required String userId,
    required int score,
    required int streak,
  }) async {
    try {
      double boost = 1 + (streak * 0.03);
      int gainedRP = (score * boost).toInt();

      await supabase.rpc('increment_rp', params: {
        'user_id_input': userId,
        'rp_gain': gainedRP,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Get leaderboard with pagination
  Future<List<RoomMember>> getLeaderboard({
    required String rank,
    int page = 0,
    int pageSize = 50,
  }) async {
    try {
      final room = await getRoomByRank(rank);
      final roomId = room['id'];

      final start = page * pageSize;
      final end = start + pageSize - 1;

      final response = await supabase
          .from('room_members')
          .select('*, profiles!inner(first_name, last_name, rank)')
          .eq('room_id', roomId)
          .order('rp', ascending: false)
          .range(start, end);

      if (response.isEmpty) {
        return [];
      }

      return (response as List).map((json) {
        final profiles = json['profiles'];
        return RoomMember.fromJson({
          'id': json['id'],
          'room_id': json['room_id'],
          'user_id': json['user_id'],
          'rp': json['rp'],
          'games_played': json['games_played'],
          'first_name': profiles['first_name'],
          'last_name': profiles['last_name'],
          'rank': profiles['rank'],
        });
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get user's position in their rank
  Future<int?> getUserRankPosition(String userId) async {
    final profile = await supabase
        .from('profiles')
        .select('rank')
        .eq('id', userId)
        .single();

    final userRank = profile['rank'];
    final room = await getRoomByRank(userRank);
    final roomId = room['id'];

    // Get all members sorted by RP
    final members = await supabase
        .from('room_members')
        .select('user_id, rp')
        .eq('room_id', roomId)
        .order('rp', ascending: false);

    // Find user's position
    for (int i = 0; i < members.length; i++) {
      if (members[i]['user_id'] == userId) {
        return i + 1;
      }
    }

    return null;
  }

  // Get total player count in a room
  Future<int> getRoomPlayerCount(String rank) async {
    final room = await getRoomByRank(rank);
    final roomId = room['id'];

    final response = await supabase
        .from('room_members')
        .select('id')
        .eq('room_id', roomId)
        .count(CountOption.exact);

    return response.count;
  }

  // Test ranked results (manual promotion/demotion)
  Future<Map<String, dynamic>> testRankedResults() async {
    try {
      final response = await supabase.rpc('test_ranked_results');
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }
}
