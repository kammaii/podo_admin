import 'package:uuid/uuid.dart';

class Reading {
  late String id;
  late int orderId;
  late Map<String, dynamic> content;
  late Map<String, dynamic> words;

  Reading(int index) {
    id = const Uuid().v4();
    orderId = index;
    content = {};
    words = {};
  }

  static const String ID = 'id';
  static const String ORDERID = 'orderId';
  static const String CONTENT = 'content';
  static const String WORDS = 'words';

  Reading.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    orderId = json[ORDERID];
    content = json[CONTENT] ?? {};
    words = json[WORDS];
  }

  Map<String, dynamic> toJson() => {
        ID: id,
        ORDERID: orderId,
        CONTENT: content,
        WORDS: words,
      };
}
