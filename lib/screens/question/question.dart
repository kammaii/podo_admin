import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  late String questionId;
  late String userEmail;
  late String question;
  String? answer;
  late DateTime questionDate;
  DateTime? answerDate;
  String? tag;
  late int status;

  static const String QUESTIONID = 'questionId';
  static const String USEREMAIL = 'userEmail';
  static const String QUESTION = 'question';
  static const String ANSWER = 'answer';
  static const String QUESTIONDATE = 'questionDate';
  static const String ANSWERDATE = 'answerDate';
  static const String TAG = 'tag';
  static const String STATUS = 'status';

  Question.fromJson(Map<String, dynamic> json) {
    questionId = json[QUESTIONID];
    userEmail = json[USEREMAIL];
    question = json[QUESTION];
    answer = json[ANSWER];
    Timestamp questionStamp = json[QUESTIONDATE];
    questionDate = questionStamp.toDate();
    if (json[ANSWERDATE] != null) {
      Timestamp answerStamp = json[ANSWERDATE];
      answerDate = answerStamp.toDate();
      tag = json[TAG];
    }
    status = json[STATUS];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      QUESTIONID: questionId,
      USEREMAIL: userEmail,
      QUESTION: question,
      QUESTIONDATE: Timestamp.fromDate(questionDate),
      STATUS: status,
    };
    if(answer != null) {
      map[ANSWER] = answer;
    }
    if(tag != null) {
      map[TAG] = tag;
    }
    if(answerDate != null) {
      map[ANSWERDATE] = Timestamp.fromDate(answerDate!);
    }
    return map;
  }

}
