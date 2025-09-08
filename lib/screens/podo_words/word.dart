
class Word {
  final String id;
  final int orderId;
  final String front;
  final String back;
  final String pronunciation;
  final String audio;
  final String? image;

  int? wordId;
  bool isActive = true;
  bool isChecked = false;
  bool? shouldQuiz;


  Word({
    required this.id,
    required this.orderId,
    required this.front,
    required this.back,
    required this.pronunciation,
    required this.audio,
    this.image,
  });

  Map<String, dynamic> toJson() => {
    'front' : front,
    'back' : back,
    'pronunciation' : pronunciation,
    'audio' : audio,
    'image' : image
  };

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'] as String,
      orderId: json['orderId'] as int,
      front: json['front'] as String,
      back: json['back'] as String,
      pronunciation: json['pronunciation'] as String,
      audio: json['audio'] as String,
      image: json['image'] as String?,
    );
  }
}