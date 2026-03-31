import 'dart:async';
import 'package:flutter/material.dart';
import '../controllers/game_controller.dart';
import '../services/level_data.dart';
import 'widgets/flow_grid.dart';
import 'widgets/game_hud.dart';
import 'widgets/win_dialog.dart';

class FlowPage extends StatefulWidget {
  const FlowPage({super.key});

  @override
  State<FlowPage> createState() => _FlowPageState();
}

class _FlowPageState extends State<FlowPage> {
  late FlowGameController controller;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    controller = FlowGameController(level: 1);
    controller.addListener(_onGameStateChanged);
    _startTimer();
  }

  void _startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted && !controller.state.isComplete) {
        controller.updateTime(controller.state.time + 1);
      }
    });
  }

  void _onGameStateChanged() {
    if (controller.state.isComplete) {
      timer?.cancel();
      _showWinDialog();
    }
  }

  void _showWinDialog() {
    final level = controller.state.level;
    final rewards = levelRewards[level] ?? {'xp': 50, 'rp': 10};
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WinDialog(
        level: level,
        moves: controller.state.moves,
        time: controller.state.time,
        xpEarned: rewards['xp']!,
        rpEarned: rewards['rp']!,
        onRestart: () {
          Navigator.pop(context);
          controller.restartLevel();
          _startTimer();
        },
        onNextLevel: () {
          Navigator.pop(context);
          controller.nextLevel();
          _startTimer();
        },
      ),
    );
  }

  void _restartLevel() {
    controller.restartLevel();
    _startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    controller.removeListener(_onGameStateChanged);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A24), Color(0xFF2C2C3E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: controller,
              builder: (context, child) => FlowGrid(controller: controller),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, child) => GameHud(
                  level: controller.state.level,
                  moves: controller.state.moves,
                  time: controller.state.time,
                  onRestart: _restartLevel,
                  onBack: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}