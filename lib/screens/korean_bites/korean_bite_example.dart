import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class KoreanBiteExample {

  late String id;
  late int orderId;
  late String example;  //html
  late Map<String, dynamic> exampleTrans;
  String? pronunciation;
  bool isPlay = false;

  KoreanBiteExample(int index) {
    id = const Uuid().v4();
    orderId = index;
    example = '';
    exampleTrans = {};
  }

  static const String ID = 'id';
  static const String ORDER_ID = 'orderId';
  static const String EXAMPLE = 'example';
  static const String EXAMPLE_TRANS = 'exampleTrans';
  static const String PRONUNCIATION = 'pronunciation';

  KoreanBiteExample.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    orderId = json[ORDER_ID];
    example = json[EXAMPLE];
    exampleTrans = json[EXAMPLE_TRANS];
    if(json[PRONUNCIATION] != null) {
      pronunciation = json[PRONUNCIATION];
    }
  }

  Map<String, dynamic> toJson() => {
    ID: id,
    ORDER_ID: orderId,
    EXAMPLE: example,
    EXAMPLE_TRANS: exampleTrans,
    PRONUNCIATION: pronunciation,
  };
}