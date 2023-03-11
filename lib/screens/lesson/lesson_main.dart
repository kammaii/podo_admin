import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/common/my_radio_btn.dart';
import 'package:podo_admin/screens/lesson/lesson_state_manager.dart';
import 'package:podo_admin/screens/lesson/lesson_subject.dart';
import 'package:podo_admin/screens/lesson/lesson_subject_main.dart';
import 'package:podo_admin/screens/lesson/lesson_title.dart';
import 'package:podo_admin/screens/lesson/lesson_title_main.dart';

class LessonMain extends StatefulWidget {
  LessonMain({Key? key}) : super(key: key);

  @override
  State<LessonMain> createState() => _LessonMainState();
}

class _LessonMainState extends State<LessonMain> {
  List<bool> selectedToggle = [true, false];
  String selectedLevel = '초급';
  List<LessonSubject> lessonSubjects = [];
  List<LessonTitle> lessonTitles = [];
  late Future<List<dynamic>> future;


  @override
  Widget build(BuildContext context) {

    if(selectedToggle[0] && lessonSubjects.isEmpty) {
      selectedLevel == '초급'
          ? future = Database().getDocumentsFromDb(
          reference: 'LessonSubjects', query: 'isBeginnerMode', equalTo: true, orderBy: 'orderId', descending: false)
          : future = Database().getDocumentsFromDb(
          reference: 'LessonSubjects', query: 'isBeginnerMode', equalTo: false, orderBy: 'orderId', descending: false);
    }

    if(selectedToggle[1] && lessonTitles.isEmpty) {
       future = Database().getDocumentsFromDb(
          reference: 'LessonTitles', orderBy: 'isFree');
    }

    Widget getRadioBtn(String title) {
      return MyRadioBtn().getRadioButton(
        context: context,
        title: title,
        radio: selectedLevel,
        f: (String? value) {
          setState(() {
            selectedLevel = value!;
          });
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('레슨'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ToggleButtons(
                      onPressed: (int index) {
                        setState(() {
                          for (int i = 0; i < selectedToggle.length; i++) {
                            selectedToggle[i] = i == index;
                          }
                        });
                      },
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      selectedBorderColor: Theme
                          .of(context)
                          .colorScheme
                          .primary,
                      selectedColor: Colors.white,
                      fillColor: Theme
                          .of(context)
                          .colorScheme
                          .primary,
                      color: Theme
                          .of(context)
                          .colorScheme
                          .primary,
                      isSelected: selectedToggle,
                      children: const [
                        Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('주제')),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('타이틀')),
                      ],
                    ),
                    const SizedBox(width: 20),
                    selectedToggle[0] ? getRadioBtn('초급') : const SizedBox.shrink(),
                    selectedToggle[0] ? getRadioBtn('중급') : const SizedBox.shrink(),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {

                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      '추가하기',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: selectedToggle[0] ? LessonSubjectMain(future, selectedLevel == '초급' ? true : false).subjectTable : LessonTitleMain(future).titleTable,
            ),
          ],
        ),
      ),
    );
  }
}

class SampleLessonTitles {
  List<String> titles = [];

  List<String> getTitles() {
    return titles;
  }
}
