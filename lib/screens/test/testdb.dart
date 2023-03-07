import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/screens/question/question.dart';

class TestDB extends StatelessWidget {
  const TestDB({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: (){
            makeQuestionDb();
          },
          child: const Text('make question db'),
        ),
      ],
    );
  }

  makeQuestionDb() {
    List<Question> questions = getSampleQuestions();
    for(Question question in questions) {
      Database().saveSampleQuestion(question);
    }
  }

  static const String QUESTIONID = 'questionId';
  static const String USEREMAIL = 'userEmail';
  static const String QUESTION = 'question';
  static const String ANSWER = 'answer';
  static const String QUESTIONDATE = 'questionDate';
  static const String ANSWERDATE = 'answerDate';
  static const String TAG = 'tag';
  static const String STATUS = 'status';

  List<Question> getSampleQuestions() {
    Map<String, dynamic> sampleJson1 = {
      QUESTION: 'question1 ~~',
      USEREMAIL: 'sample1@gmail.com',
      QUESTIONDATE: Timestamp.now(),
      STATUS: 0,
    };

    Map<String, dynamic> sampleJson2 = {
      QUESTION: 'question2 ~~',
      USEREMAIL: 'sample2@gmail.com',
      QUESTIONDATE: Timestamp.now(),
      STATUS: 0,
    };

    Map<String, dynamic> sampleJson3 = {
      QUESTION: 'question3 ~~',
      USEREMAIL: 'sample2@gmail.com',
      QUESTIONDATE: Timestamp.now(),
      ANSWER: 'answer~~',
      ANSWERDATE: Timestamp.now(),
      TAG: 'grammar',
      STATUS: 1,
    };
    Map<String, dynamic> sampleJson4 = {
      QUESTION: 'question4 ~~',
      USEREMAIL: 'sample3@gmail.com',
      QUESTIONDATE: Timestamp.now(),
      ANSWER: 'answer~~',
      ANSWERDATE: Timestamp.now(),
      TAG: 'pronunciation',
      STATUS: 4,
    };

    return [Question.fromJson(sampleJson1), Question.fromJson(sampleJson2), Question.fromJson(sampleJson3), Question.fromJson(sampleJson4)];
  }
}
