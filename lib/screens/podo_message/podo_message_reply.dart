import 'package:cloud_firestore/cloud_firestore.dart';

class PodoMessageReply {
  late String id;
  late String userId;
  late String userName;
  late String reply;
  late DateTime date;
  late bool isSelected;


  static const String ID = 'id';
  static const String USERID = 'userId';
  static const String USERNAME = 'userName';
  static const String REPLY = 'reply';
  static const String DATE = 'date';
  static const String ISSELECTED = 'isSelected';


  PodoMessageReply.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    userId = json[USERID];
    userName = json[USERNAME];
    reply = json[REPLY];
    Timestamp stamp = json[DATE];
    date = stamp.toDate();
    isSelected = json[ISSELECTED];
  }
}