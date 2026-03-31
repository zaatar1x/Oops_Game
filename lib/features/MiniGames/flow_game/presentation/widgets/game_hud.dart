import 'package:flutter/material.dart';

class GameHud extends StatelessWidget {
  final int level;
  final int moves;
  final int time;
  final VoidCallback onRestart;
  final VoidCallback onBack;

  const GameHud({
    super.key,
    required this.level,
    required this.moves,
    required this.time,
    required this.onRestart,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF2C2C3E).withValues(alpha: 0.95),
                const Color(0xFF1A1A24).withValues(alpha: 0.95),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded,
                    color: Colors.white, size: 20),
                onPressed: onBack,
              ),
              _buildStat(Icons.grid_4x4_rounded, "Lv $level"),
              _buildStat(Icons.timer_outlined, "${time}s"),
              _buildStat(Icons.touch_app_outlined, "$moves"),
              IconButton(
                icon: const Icon(Icons.refresh_rounded,
                    color: Colors.white, size: 24),
                onPressed: onRestart,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
