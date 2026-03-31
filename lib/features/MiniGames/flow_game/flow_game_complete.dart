import 'dart:async';
import 'package:flutter/material.dart';
import 'core/flow_engine.dart';
import 'services/level_data.dart';
import '../../auth/data/auth_service.dart';
import '../../ranking/data/ranking_service.dart';

/// COMPLETE FLOW GAME - Production-ready implementation
class FlowGameComplete extends StatefulWidget {
  const FlowGameComplete({super.key});

  @override
  State<FlowGameComplete> createState() => _FlowGameCompleteState();
}

class _FlowGameCompleteState extends State<FlowGameComplete> {
  final authService = AuthService();
  final rankingService = RankingService();
  
  int currentLevel = 0;
  late FlowGrid grid;
  late Map<String, List<Point>> nodes;
  
  String? activeColor;
  Point? lastCell;
  int moves = 0;
  int time = 0;
  Timer? timer;
  double cellSize = 0;

  @override
  void initState() {
    super.initState();
    _loadLevel(currentLevel);
    _startTimer();
  }

  void _loadLevel(int level) {
    // Use static levels (guaranteed working)
    final levelData = allLevels[level % allLevels.length];
    final size = levelData.length;
    
    grid = FlowGrid(size);
    nodes = {};
    
    // Parse level data
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        final color = levelData[r][c];
        if (color != null) {
          grid.getCell(r, c).setNode(color);
          nodes.putIfAbsent(color, () => []);
          nodes[color]!.add(Point(r, c));
        }
      }
    }
    
    activeColor = null;
    lastCell = null;
    moves = 0;
  }

  void _startTimer() {
    timer?.cancel();
    time = 0;
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) setState(() => time++);
    });
  }

  void _handleTouch(Offset position) {
    final row = (position.dy / cellSize).floor();
    final col = (position.dx / cellSize).floor();

    if (!grid.isValid(row, col)) return;

    final cell = grid.getCell(row, col);
    final point = Point(row, col);

    // Start new path
    if (activeColor == null) {
      if (cell.isNode) {
        setState(() {
          activeColor = cell.color;
          lastCell = point;
          _clearPath(cell.color!);
        });
      }
    } else {
      // Continue path
      if (point == lastCell) return;
      
      // Fill all cells between last and current (Manhattan interpolation)
      final cellsToFill = _getManhattanPath(lastCell!, point);
      
      bool canContinue = true;
      for (final p in cellsToFill) {
        final c = grid.getCell(p.row, p.col);
        // Can only move to empty cells or same color or target node
        if (!c.isEmpty && c.color != activeColor) {
          canContinue = false;
          break;
        }
      }
      
      if (canContinue && cellsToFill.isNotEmpty) {
        setState(() {
          for (final p in cellsToFill) {
            final c = grid.getCell(p.row, p.col);
            if (c.isEmpty) {
              c.setPath(activeColor!);
            }
          }
          lastCell = point;
          moves++;
        });
      }
    }
  }

  void _handleEnd() {
    setState(() {
      activeColor = null;
      lastCell = null;
    });
  }

  /// Manhattan path interpolation (no skipped cells)
  List<Point> _getManhattanPath(Point start, Point end) {
    final cells = <Point>[];
    int r = start.row;
    int c = start.col;
    
    // Move horizontally first
    while (c != end.col) {
      c += (c < end.col) ? 1 : -1;
      cells.add(Point(r, c));
    }
    
    // Then vertically
    while (r != end.row) {
      r += (r < end.row) ? 1 : -1;
      cells.add(Point(r, c));
    }
    
    return cells;
  }

  void _clearPath(String color) {
    for (var row in grid.cells) {
      for (var cell in row) {
        if (cell.isPath && cell.color == color) {
          cell.clear();
        }
      }
    }
    
    // Restore nodes
    for (final nodePoint in nodes[color]!) {
      grid.getCell(nodePoint.row, nodePoint.col).setNode(color);
    }
  }

  void _verify() {
    if (FlowValidator.validateSolution(grid, nodes)) {
      timer?.cancel();
      _showSuccess();
    } else {
      // Count connected pairs
      int connected = 0;
      for (final entry in nodes.entries) {
        if (entry.value.length == 2) {
          if (FlowValidator.areNodesConnected(
            grid, entry.value[0], entry.value[1], entry.key)) {
            connected++;
          }
        }
      }
      _showError('Connect all pairs! ($connected/${nodes.length})');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFFF5252),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess() async {
    final level = currentLevel + 1;
    final rewards = levelRewards[level] ?? {'xp': 50, 'rp': 10};
    final xpEarned = rewards['xp']!;
    final rpEarned = rewards['rp']!;

    // Award XP and RP to player
    try {
      final user = authService.currentUser;
      if (user != null) {
        // Update XP (and streak, games played, level)
        final newStreak = await authService.updateProfileAfterQuiz(
          scoreEarned: xpEarned,
        );
        
        // Update RP in ranking system
        await rankingService.updateRP(
          userId: user.id,
          score: rpEarned,
          streak: newStreak,
        );
        
        print('✅ Flow Game Rewards: +$xpEarned XP, +$rpEarned RP (Streak: $newStreak)');
      }
    } catch (e) {
      print('❌ Error awarding Flow game rewards: $e');
      // Continue anyway - don't block the user
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF00C9A7)]),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events_rounded, size: 80, color: Colors.white),
              const SizedBox(height: 16),
              const Text('Level Complete!',
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Text('+$xpEarned XP  |  +$rpEarned RP',
                style: const TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
        ),
      ),
    );

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
              Expanded(child: _buildGame()),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Text('Level ${currentLevel + 1}',
            style: const TextStyle(color: Colors.white, fontSize: 20)),
          Text('${time}s',
            style: const TextStyle(color: Colors.white, fontSize: 16)),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => setState(() {
              _loadLevel(currentLevel);
              _startTimer();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildGame() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth - 40
            : constraints.maxHeight - 40;
        cellSize = size / grid.size;

        return Center(
          child: RepaintBoundary(
            child: GestureDetector(
              onPanDown: (d) => _handleTouch(d.localPosition),
              onPanUpdate: (d) => _handleTouch(d.localPosition),
              onPanEnd: (_) => _handleEnd(),
              child: CustomPaint(
                size: Size(size, size),
                painter: FlowPainter(grid: grid, cellSize: cellSize),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerifyButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: _verify,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00B0FF),
          minimumSize: const Size(double.infinity, 60),
        ),
        child: const Text('Verify', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}

class FlowPainter extends CustomPainter {
  final FlowGrid grid;
  final double cellSize;

  FlowPainter({required this.grid, required this.cellSize});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background
    final bgPaint = Paint()..color = const Color(0xFF0D0D15);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
    
    // Draw grid borders (more visible)
    final gridPaint = Paint()
      ..color = const Color(0xFF3A3A4A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 0; i <= grid.size; i++) {
      canvas.drawLine(
        Offset(0, i * cellSize),
        Offset(grid.size * cellSize, i * cellSize),
        gridPaint,
      );
      canvas.drawLine(
        Offset(i * cellSize, 0),
        Offset(i * cellSize, grid.size * cellSize),
        gridPaint,
      );
    }
    
    // Draw outer border (extra visible)
    final outerBorderPaint = Paint()
      ..color = const Color(0xFF5A5A6A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, grid.size * cellSize, grid.size * cellSize),
      outerBorderPaint,
    );

    // Draw neon lines connecting path cells
    _drawNeonLines(canvas);
    
    // Draw nodes on top
    _drawNodes(canvas);
  }
  
  void _drawNeonLines(Canvas canvas) {
    // Group cells by color and build paths
    final colorPaths = <String, Path>{};
    final colorPoints = <String, Set<String>>{};
    
    for (var row in grid.cells) {
      for (var cell in row) {
        if ((cell.isPath || cell.isNode) && cell.color != null) {
          colorPoints.putIfAbsent(cell.color!, () => {});
          colorPoints[cell.color!]!.add('${cell.row},${cell.col}');
        }
      }
    }
    
    // Build paths for each color
    for (var entry in colorPoints.entries) {
      final color = entry.key;
      final points = entry.value;
      
      if (points.length < 2) continue;
      
      final path = Path();
      final visited = <String>{};
      
      // Build connected path
      for (var pointKey in points) {
        if (visited.contains(pointKey)) continue;
        
        final parts = pointKey.split(',');
        final row = int.parse(parts[0]);
        final col = int.parse(parts[1]);
        
        final center = Offset(
          col * cellSize + cellSize / 2,
          row * cellSize + cellSize / 2,
        );
        
        visited.add(pointKey);
        
        // Find adjacent cells
        for (var otherKey in points) {
          if (pointKey == otherKey) continue;
          
          final otherParts = otherKey.split(',');
          final otherRow = int.parse(otherParts[0]);
          final otherCol = int.parse(otherParts[1]);
          
          final rowDiff = (row - otherRow).abs();
          final colDiff = (col - otherCol).abs();
          
          if ((rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1)) {
            final otherCenter = Offset(
              otherCol * cellSize + cellSize / 2,
              otherRow * cellSize + cellSize / 2,
            );
            
            path.moveTo(center.dx, center.dy);
            path.lineTo(otherCenter.dx, otherCenter.dy);
          }
        }
      }
      
      colorPaths[color] = path;
    }
    
    // Draw paths with neon effect (optimized - only 2 layers)
    for (var entry in colorPaths.entries) {
      final color = entry.key;
      final path = entry.value;
      final baseColor = _getColor(color);
      
      // Single glow layer
      final glowPaint = Paint()
        ..color = baseColor.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = cellSize * 0.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
      
      canvas.drawPath(path, glowPaint);
      
      // Main bright line
      final mainPaint = Paint()
        ..color = baseColor.withValues(alpha: 0.95)
        ..style = PaintingStyle.stroke
        ..strokeWidth = cellSize * 0.3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      
      canvas.drawPath(path, mainPaint);
    }
  }
  
  void _drawNodes(Canvas canvas) {
    for (var row in grid.cells) {
      for (var cell in row) {
        if (cell.isNode) {
          final center = Offset(
            cell.col * cellSize + cellSize / 2,
            cell.row * cellSize + cellSize / 2,
          );
          
          final color = _getColor(cell.color!);
          
          // Single glow layer (optimized)
          final glowPaint = Paint()
            ..color = color.withValues(alpha: 0.25)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
          canvas.drawCircle(center, cellSize / 2.8, glowPaint);
          
          // Main node
          final nodePaint = Paint()..color = color;
          canvas.drawCircle(center, cellSize / 3.5, nodePaint);
          
          // Inner highlight
          final highlightPaint = Paint()
            ..color = Colors.white.withValues(alpha: 0.35);
          canvas.drawCircle(
            center.translate(-cellSize / 12, -cellSize / 12),
            cellSize / 9,
            highlightPaint,
          );
        }
      }
    }
  }

  Color _getColor(String color) {
    switch (color) {
      case 'red': return const Color(0xFFFF5252);
      case 'blue': return const Color(0xFF448AFF);
      case 'green': return const Color(0xFF69F0AE);
      case 'yellow': return const Color(0xFFFFD740);
      case 'purple': return const Color(0xFFE040FB);
      case 'orange': return const Color(0xFFFF9100);
      case 'pink': return const Color(0xFFFF4081);
      case 'cyan': return const Color(0xFF18FFFF);
      default: return Colors.white;
    }
  }

  @override
  bool shouldRepaint(FlowPainter oldDelegate) => true;
}
