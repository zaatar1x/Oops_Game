import 'dart:async';
import 'package:flutter/material.dart';
import 'services/level_data.dart';

class FlowGameFinal extends StatefulWidget {
  const FlowGameFinal({super.key});

  @override
  State<FlowGameFinal> createState() => _FlowGameFinalState();
}

class _FlowGameFinalState extends State<FlowGameFinal> {
  int currentLevel = 0;
  late List<List<String?>> grid;
  late List<List<String?>> paths;
  String? activeColor;
  int lastRow = -1;
  int lastCol = -1;
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
    // Option 1: Use static levels (current - guaranteed working)
    // Option 2: Use dynamic generator (new - solution-first approach)
    
    // For now, use static levels for stability
    // To enable generator, uncomment the code below:
    /*
    if (level >= allLevels.length) {
      // Generate dynamic level
      final size = 5 + ((level - allLevels.length) ~/ 3);
      final colors = 2 + ((level - allLevels.length) ~/ 2);
      final difficulty = ((level - allLevels.length) * 0.1).clamp(0.0, 1.0);
      
      final levelData = FlowLevelGenerator.generate(
        size: size.clamp(5, 10),
        colorCount: colors.clamp(2, 6),
        difficulty: difficulty,
      );
      
      grid = levelData.map((row) => List<String?>.from(row)).toList();
    } else {
      final levelData = allLevels[level % allLevels.length];
      grid = levelData.map((row) => List<String?>.from(row)).toList();
    }
    */
    
    // Current: Use static levels
    final levelData = allLevels[level % allLevels.length];
    grid = levelData.map((row) => List<String?>.from(row)).toList();
    
    paths = List.generate(grid.length, (i) => List<String?>.filled(grid.length, null));
    
    // Mark nodes in paths
    for (int r = 0; r < grid.length; r++) {
      for (int c = 0; c < grid.length; c++) {
        if (grid[r][c] != null) {
          paths[r][c] = grid[r][c];
        }
      }
    }
    
    activeColor = null;
    lastRow = -1;
    lastCol = -1;
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

    if (row < 0 || col < 0 || row >= grid.length || col >= grid.length) return;

    // Start new path
    if (activeColor == null) {
      final color = grid[row][col];
      if (color != null) {
        setState(() {
          activeColor = color;
          lastRow = row;
          lastCol = col;
          _clearPath(color);
          paths[row][col] = color;
        });
      }
    } else {
      // Continue path - fill ALL cells between last and current position
      if (row == lastRow && col == lastCol) return;
      
      // Get all cells between last position and current position
      final cellsToFill = _getManhattanPath(lastRow, lastCol, row, col);
      
      bool canContinue = true;
      for (var cell in cellsToFill) {
        final r = cell[0];
        final c = cell[1];
        
        // Check if we can place on this cell
        final existing = paths[r][c];
        // Allow: empty cells, same color cells, or target node of same color
        if (existing != null && existing != activeColor && grid[r][c] != activeColor) {
          canContinue = false;
          break;
        }
      }
      
      if (canContinue && cellsToFill.isNotEmpty) {
        setState(() {
          for (var cell in cellsToFill) {
            final r = cell[0];
            final c = cell[1];
            paths[r][c] = activeColor;
          }
          lastRow = row;
          lastCol = col;
          
          // Only increment moves when we actually add new cells
          if (cellsToFill.length > 1) {
            moves++;
          }
        });
      }
    }
  }

  // Get all cells in Manhattan path from (r1,c1) to (r2,c2)
  // This ensures NO cells are skipped during fast dragging
  List<List<int>> _getManhattanPath(int r1, int c1, int r2, int c2) {
    List<List<int>> cells = [];
    
    int currentRow = r1;
    int currentCol = c1;
    
    // Move horizontally first, then vertically (Manhattan distance)
    while (currentCol != c2) {
      if (currentCol < c2) {
        currentCol++;
      } else {
        currentCol--;
      }
      cells.add([currentRow, currentCol]);
    }
    
    while (currentRow != r2) {
      if (currentRow < r2) {
        currentRow++;
      } else {
        currentRow--;
      }
      cells.add([currentRow, currentCol]);
    }
    
    return cells;
  }

  void _handleEnd() {
    setState(() {
      activeColor = null;
      lastRow = -1;
      lastCol = -1;
    });
  }

  void _clearPath(String color) {
    for (int r = 0; r < grid.length; r++) {
      for (int c = 0; c < grid.length; c++) {
        if (paths[r][c] == color && grid[r][c] != color) {
          paths[r][c] = null;
        }
      }
    }
  }

  void _verify() {
    // Count filled cells
    int filled = 0;
    for (var row in paths) {
      for (var cell in row) {
        if (cell != null) filled++;
      }
    }

    // Get all node pairs
    final nodes = <String, List<List<int>>>{};
    for (int r = 0; r < grid.length; r++) {
      for (int c = 0; c < grid.length; c++) {
        if (grid[r][c] != null) {
          nodes.putIfAbsent(grid[r][c]!, () => []);
          nodes[grid[r][c]!]!.add([r, c]);
        }
      }
    }

    // Debug: Print grid state
    print('=== GRID STATE ===');
    for (int r = 0; r < paths.length; r++) {
      print(paths[r].map((c) => c ?? '___').join(' | '));
    }
    print('Filled: $filled / ${grid.length * grid.length}');

    // Check if each pair is properly connected via continuous path
    int connected = 0;
    final List<String> connectionStatus = [];
    for (var entry in nodes.entries) {
      if (entry.value.length == 2) {
        final start = entry.value[0];
        final end = entry.value[1];
        
        // Use BFS to check if there's a continuous path of this color connecting start to end
        final isConn = _isConnected(start[0], start[1], end[0], end[1], entry.key);
        if (isConn) {
          connected++;
          connectionStatus.add('${entry.key}: ✓');
        } else {
          connectionStatus.add('${entry.key}: ✗');
        }
      }
    }

    print('Connections: $connected / ${nodes.length}');
    print(connectionStatus.join(', '));
    print('==================');
    
    // Win condition: All pairs must be connected
    // Optional: Can also require full grid (connected == nodes.length && filled == total)
    if (connected == nodes.length) {
      timer?.cancel();
      _showSuccess();
    } else {
      _showError('Connect all pairs! ($connected/${nodes.length})');
    }
  }

  // Check if two nodes are connected via continuous path using BFS
  bool _isConnected(int startR, int startC, int endR, int endC, String color) {
    if (paths[startR][startC] != color || paths[endR][endC] != color) {
      return false;
    }

    final visited = List.generate(grid.length, (_) => List<bool>.filled(grid.length, false));
    final queue = <List<int>>[];
    
    queue.add([startR, startC]);
    visited[startR][startC] = true;

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      final r = current[0];
      final c = current[1];

      // Found the end node
      if (r == endR && c == endC) {
        return true;
      }

      // Check all 4 adjacent cells
      final directions = [[-1, 0], [1, 0], [0, -1], [0, 1]];
      for (var dir in directions) {
        final newR = r + dir[0];
        final newC = c + dir[1];

        if (newR >= 0 && newR < grid.length && 
            newC >= 0 && newC < grid.length &&
            !visited[newR][newC] &&
            paths[newR][newC] == color) {
          visited[newR][newC] = true;
          queue.add([newR, newC]);
        }
      }
    }

    return false;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFFF5252),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  void _showSuccess() {
    final level = currentLevel + 1;
    final rewards = levelRewards[level] ?? {'xp': 50, 'rp': 10};

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF00C9A7)]),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events_rounded, size: 80, color: Colors.white),
              const SizedBox(height: 16),
              const Text('Level Complete!', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFFFD740), size: 28),
                        const SizedBox(width: 8),
                        Text('+${rewards['xp']} XP', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.diamond_rounded, color: Color(0xFF00E5FF), size: 28),
                        const SizedBox(width: 8),
                        Text('+${rewards['rp']} RP', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
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
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            _buildStat(Icons.grid_4x4_rounded, "Lv ${currentLevel + 1}"),
            _buildStat(Icons.timer_outlined, "${time}s"),
            _buildStat(Icons.touch_app_outlined, "$moves"),
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
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
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
        cellSize = size / grid.length;

        return Center(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C3E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanDown: (d) => _handleTouch(d.localPosition),
                onPanUpdate: (d) => _handleTouch(d.localPosition),
                onPanEnd: (_) => _handleEnd(),
                child: CustomPaint(
                  size: Size(size, size),
                  painter: GamePainter(grid: grid, paths: paths, cellSize: cellSize),
                ),
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
      child: Container(
        width: double.infinity,
        height: 70,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF00B0FF)]),
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
            onTap: _verify,
            borderRadius: BorderRadius.circular(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                const Text('Verify & Continue', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GamePainter extends CustomPainter {
  final List<List<String?>> grid;
  final List<List<String?>> paths;
  final double cellSize;

  GamePainter({required this.grid, required this.paths, required this.cellSize});

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
    // Grid
    final gridPaint = Paint()
      ..color = const Color(0xFF1A1A24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i <= grid.length; i++) {
      canvas.drawLine(Offset(0, i * cellSize), Offset(grid.length * cellSize, i * cellSize), gridPaint);
      canvas.drawLine(Offset(i * cellSize, 0), Offset(i * cellSize, grid.length * cellSize), gridPaint);
    }

    // Draw paths as connected lines
    final pathsByColor = <String, List<List<int>>>{};
    for (int r = 0; r < paths.length; r++) {
      for (int c = 0; c < paths[r].length; c++) {
        if (paths[r][c] != null) {
          pathsByColor.putIfAbsent(paths[r][c]!, () => []);
          pathsByColor[paths[r][c]!]!.add([r, c]);
        }
      }
    }

    // Draw lines connecting adjacent cells of same color
    for (var entry in pathsByColor.entries) {
      final color = _getColor(entry.key);
      final linePaint = Paint()
        ..color = color.withValues(alpha: 0.8)
        ..strokeWidth = cellSize * 0.4
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      for (var cell in entry.value) {
        final r = cell[0];
        final c = cell[1];
        final center = Offset(c * cellSize + cellSize / 2, r * cellSize + cellSize / 2);

        // Draw lines to adjacent cells of same color
        // Check right
        if (c + 1 < paths[r].length && paths[r][c + 1] == entry.key) {
          final nextCenter = Offset((c + 1) * cellSize + cellSize / 2, r * cellSize + cellSize / 2);
          canvas.drawLine(center, nextCenter, linePaint);
        }
        // Check down
        if (r + 1 < paths.length && paths[r + 1][c] == entry.key) {
          final nextCenter = Offset(c * cellSize + cellSize / 2, (r + 1) * cellSize + cellSize / 2);
          canvas.drawLine(center, nextCenter, linePaint);
        }

        // Draw filled circle at each path cell (not a node)
        if (grid[r][c] != entry.key) {
          final circlePaint = Paint()..color = color.withValues(alpha: 0.7);
          canvas.drawCircle(center, cellSize / 5, circlePaint);
        }
      }
    }

    // Nodes (draw last so they're on top)
    for (int r = 0; r < grid.length; r++) {
      for (int c = 0; c < grid.length; c++) {
        if (grid[r][c] != null) {
          final center = Offset(c * cellSize + cellSize / 2, r * cellSize + cellSize / 2);
          final radius = cellSize / 3.5;
          final color = _getColor(grid[r][c]!);

          final glowPaint = Paint()
            ..color = color.withValues(alpha: 0.4)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
          canvas.drawCircle(center, radius + 8, glowPaint);

          final paint = Paint()..color = color;
          canvas.drawCircle(center, radius, paint);

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
  bool shouldRepaint(GamePainter oldDelegate) => true;
}
