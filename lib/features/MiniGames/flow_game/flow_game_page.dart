import 'dart:async';
import 'package:flutter/material.dart';
import 'services/level_data.dart';

class FlowGamePage extends StatefulWidget {
  const FlowGamePage({super.key});

  @override
  State<FlowGamePage> createState() => _FlowGamePageState();
}

class _FlowGamePageState extends State<FlowGamePage> {
  int currentLevel = 0;
  late List<List<String?>> grid;
  late List<List<String?>> paths;
  Map<String, List<List<int>>> activePaths = {};
  String? currentColor;
  int moves = 0;
  int time = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _loadLevel(currentLevel);
    _startTimer();
  }

  void _loadLevel(int level) {
    final levelData = allLevels[level % allLevels.length];
    grid = levelData.map((row) => List<String?>.from(row)).toList();
    paths = List.generate(grid.length, (_) => List<String?>.filled(grid.length, null));
    activePaths.clear();
    moves = 0;
    currentColor = null;
  }

  void _startTimer() {
    timer?.cancel();
    time = 0;
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) setState(() => time++);
    });
  }

  void _onPanStart(Offset localPosition, double cellSize) {
    final row = (localPosition.dy / cellSize).floor();
    final col = (localPosition.dx / cellSize).floor();

    if (row < 0 || col < 0 || row >= grid.length || col >= grid.length) return;

    final color = grid[row][col];
    
    if (color != null) {
      setState(() {
        currentColor = color;
        _clearPath(color);
        activePaths[color] = [[row, col]];
        paths[row][col] = color;
      });
    }
  }

  void _onPanUpdate(Offset localPosition, double cellSize) {
    if (currentColor == null) return;

    final row = (localPosition.dy / cellSize).floor();
    final col = (localPosition.dx / cellSize).floor();

    if (row < 0 || col < 0 || row >= grid.length || col >= grid.length) return;

    final path = activePaths[currentColor!];
    if (path == null || path.isEmpty) return;

    final lastPos = path.last;
    final lastRow = lastPos[0];
    final lastCol = lastPos[1];

    // Same cell - skip
    if (row == lastRow && col == lastCol) return;

    // Check if adjacent (only horizontal or vertical, distance = 1)
    final distance = (row - lastRow).abs() + (col - lastCol).abs();
    if (distance != 1) return;

    // Check if backtracking
    if (path.length > 1) {
      final secondLast = path[path.length - 2];
      if (secondLast[0] == row && secondLast[1] == col) {
        setState(() {
          path.removeLast();
          paths[lastRow][lastCol] = null;
        });
        return;
      }
    }

    // Check if cell is already occupied by another color
    final existingColor = paths[row][col];
    if (existingColor != null && existingColor != currentColor) {
      // Only allow if it's the target node
      if (grid[row][col] != currentColor) return;
    }

    // Add to path
    setState(() {
      path.add([row, col]);
      paths[row][col] = currentColor;
      moves++;
    });
  }

  void _onPanEnd() {
    // Keep the path in activePaths so lines remain visible
    setState(() => currentColor = null);
  }

  void _verifyAndAdvance() {
    // Count filled cells
    int filledCells = 0;
    int totalCells = grid.length * grid.length;
    
    for (var row in paths) {
      for (var cell in row) {
        if (cell != null) filledCells++;
      }
    }
    
    // Check if all cells filled
    if (filledCells < totalCells) {
      _showError('Complete all connections! ($filledCells/$totalCells cells filled)');
      return;
    }

    // Get all color node pairs
    final colorNodes = <String, List<List<int>>>{};
    for (int r = 0; r < grid.length; r++) {
      for (int c = 0; c < grid.length; c++) {
        final color = grid[r][c];
        if (color != null) {
          colorNodes.putIfAbsent(color, () => []);
          colorNodes[color]!.add([r, c]);
        }
      }
    }

    // Verify each color pair is connected
    for (var entry in colorNodes.entries) {
      final color = entry.key;
      final nodes = entry.value;
      
      if (nodes.length != 2) continue;
      
      final start = nodes[0];
      final end = nodes[1];

      // Check if both nodes have the correct color in paths
      if (paths[start[0]][start[1]] != color || paths[end[0]][end[1]] != color) {
        _showError('$color is not properly connected!');
        return;
      }
    }

    // Success!
    timer?.cancel();
    _showWinAndAdvance();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: const Color(0xFFFF5252),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _clearPath(String color) {
    for (int r = 0; r < grid.length; r++) {
      for (int c = 0; c < grid.length; c++) {
        if (paths[r][c] == color) {
          paths[r][c] = null;
        }
      }
    }
    activePaths.remove(color);
  }

  void _showWinAndAdvance() {
    final level = currentLevel + 1;
    final rewards = levelRewards[level] ?? {'xp': 50, 'rp': 10};

    // Show win overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF00C9A7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events_rounded, size: 80, color: Colors.white),
              const SizedBox(height: 16),
              const Text(
                'Level Complete!',
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Level $level',
                style: const TextStyle(color: Colors.white70, fontSize: 18),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                ),
                child: Column(
                  children: [
                    const Text('Rewards Earned!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildReward(Icons.star_rounded, '+${rewards['xp']} XP', const Color(0xFFFFD740)),
                        _buildReward(Icons.diamond_rounded, '+${rewards['rp']} RP', const Color(0xFF00E5FF)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Loading next level...',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );

    // Auto-advance to next level after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
        setState(() {
          currentLevel = (currentLevel + 1) % allLevels.length;
          _loadLevel(currentLevel);
          _startTimer();
        });
      }
    });
  }

  Widget _buildReward(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  void dispose() {
    timer?.cancel();
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
        child: SafeArea(
          child: Column(
            children: [
              _buildHud(),
              Expanded(child: _buildGrid()),
              _buildVerifyButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHud() {
    return Padding(
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
              icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            _buildHudStat(Icons.grid_4x4_rounded, "Lv ${currentLevel + 1}"),
            _buildHudStat(Icons.timer_outlined, "${time}s"),
            _buildHudStat(Icons.touch_app_outlined, "$moves"),
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 24),
              onPressed: () => setState(() {
                _loadLevel(currentLevel);
                _startTimer();
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHudStat(IconData icon, String value) {
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
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildVerifyButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        height: 70,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00E5FF), Color(0xFF00B0FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00B0FF).withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _verifyAndAdvance,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Verify & Continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth - 40
            : constraints.maxHeight - 40;
        final cellSize = size / grid.length;

        return Center(
          child: GestureDetector(
            onPanStart: (details) => _onPanStart(details.localPosition, cellSize),
            onPanUpdate: (details) => _onPanUpdate(details.localPosition, cellSize),
            onPanEnd: (_) => _onPanEnd(),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C3E),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CustomPaint(
                  painter: FlowPainter(
                    grid: grid,
                    paths: paths,
                    activePaths: activePaths,
                    cellSize: cellSize,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class FlowPainter extends CustomPainter {
  final List<List<String?>> grid;
  final List<List<String?>> paths;
  final Map<String, List<List<int>>> activePaths;
  final double cellSize;

  FlowPainter({
    required this.grid,
    required this.paths,
    required this.activePaths,
    required this.cellSize,
  });

  Color _getColor(String color) {
    switch (color) {
      case "red": return const Color(0xFFFF5252);
      case "blue": return const Color(0xFF448AFF);
      case "green": return const Color(0xFF69F0AE);
      case "yellow": return const Color(0xFFFFD740);
      case "purple": return const Color(0xFFE040FB);
      case "orange": return const Color(0xFFFF9100);
      case "pink": return const Color(0xFFFF4081);
      case "cyan": return const Color(0xFF18FFFF);
      default: return Colors.white;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas);
    _drawLines(canvas);
    _drawNodes(canvas);
  }

  void _drawGrid(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFF1A1A24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i <= grid.length; i++) {
      canvas.drawLine(Offset(0, i * cellSize), Offset(grid.length * cellSize, i * cellSize), paint);
      canvas.drawLine(Offset(i * cellSize, 0), Offset(i * cellSize, grid.length * cellSize), paint);
    }
  }

  void _drawLines(Canvas canvas) {
    for (var entry in activePaths.entries) {
      final color = entry.key;
      final path = entry.value;
      if (path.length < 2) continue;

      final lineColor = _getColor(color);

      // Glow
      final glowPaint = Paint()
        ..color = lineColor.withValues(alpha: 0.3)
        ..strokeWidth = cellSize * 0.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      final glowPath = Path();
      glowPath.moveTo(path[0][1] * cellSize + cellSize / 2, path[0][0] * cellSize + cellSize / 2);
      for (int i = 1; i < path.length; i++) {
        glowPath.lineTo(path[i][1] * cellSize + cellSize / 2, path[i][0] * cellSize + cellSize / 2);
      }
      canvas.drawPath(glowPath, glowPaint);

      // Main line
      final linePaint = Paint()
        ..color = lineColor.withValues(alpha: 0.9)
        ..strokeWidth = cellSize * 0.25
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      canvas.drawPath(glowPath, linePaint);

      // Highlight
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..strokeWidth = cellSize * 0.12
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      canvas.drawPath(glowPath, highlightPaint);
    }
  }

  void _drawNodes(Canvas canvas) {
    for (int r = 0; r < grid.length; r++) {
      for (int c = 0; c < grid.length; c++) {
        final color = grid[r][c];
        if (color != null) {
          final center = Offset(c * cellSize + cellSize / 2, r * cellSize + cellSize / 2);
          final radius = cellSize / 3.5;

          // Glow
          final glowPaint = Paint()
            ..color = _getColor(color).withValues(alpha: 0.4)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
          canvas.drawCircle(center, radius + 8, glowPaint);

          // Main circle
          final rect = Rect.fromCircle(center: center, radius: radius);
          final gradient = RadialGradient(colors: [_getColor(color), _getColor(color).withValues(alpha: 0.7)]);
          final paint = Paint()..shader = gradient.createShader(rect);
          canvas.drawCircle(center, radius, paint);

          // Highlight
          final highlightPaint = Paint()..color = Colors.white.withValues(alpha: 0.5);
          canvas.drawCircle(Offset(center.dx - radius / 4, center.dy - radius / 4), radius / 3, highlightPaint);

          // Border
          final borderPaint = Paint()
            ..color = Colors.white.withValues(alpha: 0.7)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5;
          canvas.drawCircle(center, radius, borderPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(FlowPainter oldDelegate) => true;
}
