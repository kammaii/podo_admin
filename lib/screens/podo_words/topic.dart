import 'package:uuid/uuid.dart';

class Topic {
  late final String id;
  late int orderId;
  late String title;
  String? image;
  late bool isReleased;

  static const String ID = 'id';
  static const String ORDERID = 'orderId';
  static const String TITLE = 'title';
  static const String IMAGE = 'image';
  static const String IS_RELEASED = 'isReleased';

  Topic(int index) {
    id = const Uuid().v4();
    orderId = index;
    title = '';
    isReleased = false;
  }

  Topic.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    orderId = json[ORDERID];
    title = json[TITLE];
    if(json[IMAGE] != null) {
      image = json[IMAGE];
    }
    isReleased = json[IS_RELEASED];
  }

  Map<String, dynamic> toJson() => {
    ID: id,
    ORDERID: orderId,
    TITLE: title,
    IMAGE: image,
    IS_RELEASED: isReleased,
  };
}