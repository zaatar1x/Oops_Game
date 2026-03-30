import '../models/memory_card_model.dart';
import 'dart:math';

class MemoryService {
  List<String> images = [
    '🍎','🍌','🍇','🍓','🍉','🍒','🍍','🥝','🥑','🍑'
  ];

  List<MemoryCardModel> generate(String difficulty) {
    int pairs = difficulty == 'hard' ? 10 : difficulty == 'medium' ? 8 : 6;

    final selected = images.take(pairs).toList();

    List<MemoryCardModel> cards = [];

    int id = 0;
    for (var img in selected) {
      cards.add(MemoryCardModel(id: id++, image: img));
      cards.add(MemoryCardModel(id: id++, image: img));
    }

    cards.shuffle(Random());

    return cards;
  }
}