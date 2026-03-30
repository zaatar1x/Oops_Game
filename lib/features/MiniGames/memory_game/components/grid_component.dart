import 'package:flame/components.dart';
import '../models/memory_card_model.dart';
import 'card_component.dart';

class GridComponent extends PositionComponent with HasGameRef {
  final List<MemoryCardModel> cards;
  final Function(MemoryCardModel) onCardTap;

  GridComponent({required this.cards, required this.onCardTap});

  @override
  Future<void> onLoad() async {
    // Determine grid layout based on number of cards
    int cols;
    if (cards.length <= 12) {
      cols = 4; // Easy (12 cards) and Medium (16 cards)
    } else {
      cols = 5; // Hard (20 cards)
    }

    const cardSize = 70.0;
    const spacing = 10.0;

    // Calculate grid dimensions
    final rows = (cards.length / cols).ceil();
    final gridWidth = (cols * cardSize) + ((cols - 1) * spacing);
    final gridHeight = (rows * cardSize) + ((rows - 1) * spacing);

    // Center the grid at origin (0, 0) since camera is centered
    position = Vector2(
      -gridWidth / 2,
      -gridHeight / 2,
    );

    // Add all cards to the grid
    for (int i = 0; i < cards.length; i++) {
      int row = i ~/ cols;
      int col = i % cols;

      add(CardComponent(
        model: cards[i],
        position: Vector2(
          col * (cardSize + spacing),
          row * (cardSize + spacing),
        ),
        size: Vector2.all(cardSize),
        onTap: onCardTap,
      ));
    }
  }
}