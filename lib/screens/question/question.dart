import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  late String questionId;
  late String userEmail;
  late String question;
  String? answer;
  late DateTime dateQuestion;
  DateTime? dateAnswer;
  String? tag;
  late int status;

  static const String QUESTIONID = 'questionId';
  static const String USEREMAIL = 'userEmail';
  static const String QUESTION = 'question';
  static const String ANSWER = 'answer';
  static const String DATEQUESTION = 'dateQuestion';
  static const String DATEANSWER = 'dateAnswer';
  static const String TAG = 'tag';
  static const String STATUS = 'status';

  Question.fromJson(Map<String, dynamic> json) {
    questionId = json[QUESTIONID];
    userEmail = json[USEREMAIL];
    question = json[QUESTION];
    answer = json[ANSWER];
    Timestamp questionStamp = json[DATEQUESTION];
    dateQuestion = questionStamp.toDate();
    if (json[DATEANSWER] != null) {
      Timestamp answerStamp = json[DATEANSWER];
      dateAnswer = answerStamp.toDate();
      tag = json[TAG];
    }
    status = json[STATUS];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      QUESTIONID: questionId,
      USEREMAIL: userEmail,
      QUESTION: question,
      DATEQUESTION: Timestamp.fromDate(dateQuestion),
      STATUS: status,
    };
    if(answer != null) {
      map[ANSWER] = answer;
    }
    if(tag != null) {
      map[TAG] = tag;
    }
    if(dateAnswer != null) {
      map[DATEANSWER] = Timestamp.fromDate(dateAnswer!);
    }
    return map;
  }
}
