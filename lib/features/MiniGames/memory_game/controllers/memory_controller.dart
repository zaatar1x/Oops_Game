import '../models/memory_card_model.dart';

class MemoryController {
  final List<MemoryCardModel> cards;

  MemoryCardModel? first;
  MemoryCardModel? second;

  bool isBusy = false;
  Function()? onStateChanged;

  MemoryController(this.cards);

  bool get isFinished => cards.every((c) => c.isMatched);

  void onCardTapped(MemoryCardModel card) {
    if (isBusy || card.isMatched || card.isFlipped) return;

    card.isFlipped = true;
    onStateChanged?.call();

    if (first == null) {
      first = card;
    } else {
      second = card;
      _checkMatch();
    }
  }

  void _checkMatch() async {
    isBusy = true;

    await Future.delayed(const Duration(milliseconds: 700));

    if (first!.image == second!.image) {
      first!.isMatched = true;
      second!.isMatched = true;
    } else {
      first!.isFlipped = false;
      second!.isFlipped = false;
    }

    first = null;
    second = null;
    isBusy = false;
    
    onStateChanged?.call();
  }
}