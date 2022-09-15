class LessonCard {

  late String lessonId;
  late int orderId;
  late String uniqueId;
  late String type;
  String? kr;
  String? en;
  String? pronun;
  String? explain;
  String? audio;
  String? question;
  List<String>? examples;
  bool? isFavorite;

  LessonCard({
    required this.lessonId,
    required this.orderId,
    required this.type,
    this.kr,
    this.en,
    this.pronun,
    this.explain,
    this.audio,
    this.question,
    this.examples,
    this.isFavorite,
  }) {
    setUniqueId();
  }

  void changeOrderId(int order) {
    orderId = order;
    setUniqueId();
  }

  void setUniqueId() {
    uniqueId = '${lessonId}_${orderId.toString()}';
  }

  static const String LESSONID = 'lessonId';
  static const String ORDERID = 'orderId';
  static const String UNIQUEID = 'uniqueId';
  static const String TYPE = 'type';
  static const String KR = 'kr';
  static const String EN = 'en';
  static const String PRONUN = 'pronun';
  static const String EXPLAIN = 'explain';
  static const String AUDIO = 'audio';
  static const String QUESTION = 'question';
  static const String EXAMPLES = 'examples';
  static const String ISFAVORITE = 'isFavorite';

  LessonCard.fromJson(Map<String, dynamic> json) :
    lessonId = json[LESSONID],
    orderId = json[ORDERID],
    uniqueId = json[UNIQUEID],
    type = json[TYPE],
    kr = json[KR],
    en = json[EN],
    pronun = json[PRONUN],
    explain = json[EXPLAIN],
    audio = json[AUDIO],
    question = json[QUESTION],
    examples = json[EXAMPLES],
    isFavorite = json[ISFAVORITE];

  Map<String, dynamic> toJson() => {
    LESSONID : lessonId,
    ORDERID : orderId,
    UNIQUEID : uniqueId,
    TYPE : type,
    KR : kr,
    EN : en,
    PRONUN : pronun,
    EXPLAIN : explain,
    AUDIO : audio,
    QUESTION : question,
    EXAMPLES : examples,
    ISFAVORITE : isFavorite
  };
}