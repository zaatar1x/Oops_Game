import 'package:flutter/material.dart';

class HudOverlay extends StatelessWidget {
  final int time;

  const HudOverlay({super.key, required this.time});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,
      left: 20,
      child: Text(
        "Time: $time",
        style: const TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }
}