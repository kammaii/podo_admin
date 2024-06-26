import 'package:uuid/uuid.dart';

class LessonSummary {
  late String id;
  late int orderId;
  late Map<String, dynamic> content;
  late List<dynamic> examples;

  LessonSummary(int order) {
    id = const Uuid().v4();
    content = {};
    orderId = order;
    examples = ['','','',''];
  }

  static const String ID = 'id';
  static const String ORDERID = 'orderId';
  static const String CONTENT = 'content';
  static const String EXAMPLES = 'examples';

  LessonSummary.fromJson(Map<String, dynamic> json)
      : id = json[ID],
        orderId = json[ORDERID],
        content = json[CONTENT],
        examples = json[EXAMPLES];

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      ID: id,
      ORDERID: orderId,
      CONTENT: content,
    };
    map[EXAMPLES] = examples;
    return map;
  }
}
