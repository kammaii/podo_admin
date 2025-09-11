
import 'package:uuid/uuid.dart';

class Word {
  late final String id;
  late int orderId;
  late String front;
  late String back;
  late String pronunciation;
  String? image;
  late bool isReleased;

  static const String ID = 'id';
  static const String ORDERID = 'orderId';
  static const String FRONT = 'front';
  static const String BACK = 'back';
  static const String PRONUNCIATION = 'pronunciation';
  static const String IMAGE = 'image';
  static const String IS_RELEASED = 'isReleased';

  Word(int index) {
    id = const Uuid().v4();
    orderId = index;
    front = '';
    back = '';
    pronunciation = '';
    isReleased = false;
  }

  Word.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    orderId = json[ORDERID];
    front = json[FRONT];
    back = json[BACK];
    pronunciation = json[PRONUNCIATION];
    if(json[IMAGE] != null) {
      image = json[IMAGE];
    }
    isReleased = json[IS_RELEASED];
  }

  Map<String, dynamic> toJson() => {
    ID : id,
    ORDERID : orderId,
    FRONT : front,
    BACK : back,
    PRONUNCIATION : pronunciation,
    IMAGE : image,
    IS_RELEASED : isReleased,
  };
}