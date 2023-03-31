import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/screens/lesson/lesson.dart';
import 'package:podo_admin/screens/question/question.dart';
import 'package:podo_admin/screens/writing/writing.dart';
import 'package:uuid/uuid.dart';


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
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: (){
            makeWritingDb();
          },
          child: const Text('make writing db'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: (){
            makeUserDb();
          },
          child: const Text('make user db'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async{
            List<String> q = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11'];
            int howManyTen = (q.length.toDouble()/10).floor();
            int theRest = q.length%10;
            List<Lesson> lessons = [];

            // for(int i=0; i<howManyTen; i++) {
            //   List<dynamic> l = await Database().getTest(q.sublist(0, 10));
            //   q.removeRange(0, 10);
            //   for(dynamic li in l) {
            //     titles.add(LessonTitle.fromJson(li));
            //   }
            // }
            // if(theRest != 0) {
            //   List<dynamic> l = await Database().getTest(q);
            //   for(dynamic li in l) {
            //     titles.add(LessonTitle.fromJson(li));
            //   }
            // }

            for(Lesson lesson in lessons) {
              print(lesson.title['ko']);
            }
          },
          child: const Text('test'),
        ),
      ],
    );
  }

  makeUserDb() {
    //Database().saveSampleDb(id: question.questionId, sample: question, reference: 'Questions');
  }

  makeQuestionDb() {
    List<Question> questions = getSampleQuestions();
    for(Question question in questions) {
      Database().saveSampleDb(id: question.questionId, sample: question, reference: 'Questions');
    }
  }

  makeWritingDb() {
    List<Writing> writings = getSampleWritings();
    for(Writing writing in writings) {
      Database().saveSampleDb(id: writing.writingId, sample: writing, reference: 'Writings');
    }
  }
  static const String WRITINGID = 'writingId';
  static const String WRITINGTITLE = 'writingTitle';
  static const String USEREMAIL = 'userEmail';
  static const String USERWRITING = 'userWriting';
  static const String CORRECTION = 'correction';
  static const String DATEWRITING = 'dateWriting';
  static const String DATEREPLY = 'dateReply';
  static const String STATUS = 'status';

  List<Writing> getSampleWritings() {
    Map<String, dynamic> sampleJson1 = {
      WRITINGID: const Uuid().v4(),
      WRITINGTITLE: 'writingTitle1',
      USEREMAIL: 'sample1@gmail.com',
      USERWRITING: '안냥하세여',
      DATEWRITING: Timestamp.now(),
      STATUS: 0,
    };

    Map<String, dynamic> sampleJson2 = {
      WRITINGID: const Uuid().v4(),
      WRITINGTITLE: 'writingTitle2',
      USEREMAIL: 'sample2@gmail.com',
      USERWRITING: '저는 미국사라미에여',
      DATEWRITING: Timestamp.now(),
      STATUS: 0,
    };

    Map<String, dynamic> sampleJson3 = {
      WRITINGID: const Uuid().v4(),
      WRITINGTITLE: 'writingTitle3',
      USEREMAIL: 'sample3@gmail.com',
      USERWRITING: '한구거',
      DATEWRITING: Timestamp.now(),
      STATUS: 2,
    };

    return [Writing.fromJson(sampleJson1), Writing.fromJson(sampleJson2), Writing.fromJson(sampleJson3)];
  }


  static const String QUESTIONID = 'questionId';
  static const String QUESTION = 'question';
  static const String ANSWER = 'answer';
  static const String DATEQUESTION = 'dateQuestion';
  static const String DATEANSWER = 'dateAnswer';
  static const String TAG = 'tag';

  List<Question> getSampleQuestions() {
    Map<String, dynamic> sampleJson1 = {
      QUESTIONID: const Uuid().v4(),
      QUESTION: 'question1 ~~',
      USEREMAIL: 'sample1@gmail.com',
      DATEQUESTION: Timestamp.now(),
      STATUS: 0,
    };

    Map<String, dynamic> sampleJson2 = {
      QUESTIONID: const Uuid().v4(),
      QUESTION: 'question2 ~~',
      USEREMAIL: 'sample2@gmail.com',
      DATEQUESTION: Timestamp.now(),
      STATUS: 0,
    };

    Map<String, dynamic> sampleJson3 = {
      QUESTIONID: const Uuid().v4(),
      QUESTION: 'question3 ~~',
      USEREMAIL: 'sample2@gmail.com',
      DATEQUESTION: Timestamp.now(),
      ANSWER: 'answer~~',
      DATEANSWER: Timestamp.now(),
      TAG: 'grammar',
      STATUS: 1,
    };
    Map<String, dynamic> sampleJson4 = {
      QUESTIONID: const Uuid().v4(),
      QUESTION: 'question4 ~~',
      USEREMAIL: 'sample3@gmail.com',
      DATEQUESTION: Timestamp.now(),
      ANSWER: 'answer~~',
      DATEANSWER: Timestamp.now(),
      TAG: 'pronunciation',
      STATUS: 3,
    };

    return [Question.fromJson(sampleJson1), Question.fromJson(sampleJson2), Question.fromJson(sampleJson3), Question.fromJson(sampleJson4)];
  }
}
