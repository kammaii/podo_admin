import 'package:cloud_firestore/cloud_firestore.dart';

class Feedback {
  late String id;
  late String userEmail;
  late String message;
  late DateTime date;
  late int status;

  static const String ID = 'id';
  static const String USEREMAIL = 'userEmail';
  static const String MESSAGE = 'message';
  static const String DATE = 'date';
  static const String STATUS = 'status';

  Feedback.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    userEmail = json[USEREMAIL];
    message = json[MESSAGE];
    Timestamp stamp = json[DATE];
    date = stamp.toDate();
    status = json[STATUS];
  }

  Map<String, dynamic> toJson() => {
        ID: id,
        USEREMAIL: userEmail,
        MESSAGE: message,
        DATE: Timestamp.fromDate(date),
        STATUS: status,
      };
}
