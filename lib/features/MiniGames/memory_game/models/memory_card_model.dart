class MemoryCardModel {
  final int id;
  final String image;
  bool isFlipped;
  bool isMatched;

  MemoryCardModel({
    required this.id,
    required this.image,
    this.isFlipped = false,
    this.isMatched = false,
  });
}