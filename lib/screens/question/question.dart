import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  late String questionId;
  late String userEmail;
  late String question;
  late String? answer;
  late DateTime questionDate;
  late DateTime? answerDate;
  late String? tag;
  late int status;

  Question();

  //todo: 삭제하기
  List<Question> getSampleQuestions() {
    Map<String, dynamic> sampleJson1 = {
      QUESTIONID: '0000-0000-0000',
      QUESTION: 'question1 ~~',
      USEREMAIL: 'sample1@gmail.com',
      QUESTIONDATE: Timestamp.now(),
      STATUS: 0,
    };

    Map<String, dynamic> sampleJson2 = {
      QUESTIONID: '1111-1111-1111',
      QUESTION: 'question2 ~~',
      USEREMAIL: 'sample2@gmail.com',
      QUESTIONDATE: Timestamp.now(),
      STATUS: 0,
    };

    Map<String, dynamic> sampleJson3 = {
      QUESTIONID: '2222-2222-2222',
      QUESTION: 'question3 ~~',
      USEREMAIL: 'sample2@gmail.com',
      QUESTIONDATE: Timestamp.now(),
      ANSWER: 'answer~~',
      ANSWERDATE: Timestamp.now(),
      TAG: 'grammar',
      STATUS: 1,
    };

    return [Question.fromJson(sampleJson1), Question.fromJson(sampleJson2), Question.fromJson(sampleJson3)];
  }

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

  Map<String, dynamic> toJson() => {
        QUESTIONID: questionId,
        USEREMAIL: userEmail,
        QUESTION: question,
        ANSWER: answer!,
        QUESTIONDATE: Timestamp.fromDate(questionDate),
        ANSWERDATE: Timestamp.fromDate(answerDate!),
        TAG: tag!,
        STATUS: status,
      };
}
