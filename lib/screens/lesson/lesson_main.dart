import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/common/my_radio_btn.dart';
import 'package:podo_admin/common/my_textfield.dart';
import 'package:podo_admin/screens/lesson/lesson_card_main.dart';
import 'package:podo_admin/screens/lesson/lesson_main_dialog.dart';
import 'package:podo_admin/screens/lesson/lesson_state_manager.dart';
import 'package:podo_admin/screens/lesson/lesson_course.dart';
import 'package:podo_admin/screens/lesson/lesson.dart';
import 'package:flutter/services.dart';

class LessonMain extends StatefulWidget {
  LessonMain({Key? key}) : super(key: key);

  @override
  State<LessonMain> createState() => _LessonMainState();
}

class _LessonMainState extends State<LessonMain> {
  late LessonStateManager controller;
  List<bool> selectedToggle = [true, false];
  String selectedLevel = '초급';
  late LessonMainDialog lessonMainDialog;
  late bool isBeginner;
  final LESSON_COURSES = 'LessonCourses';
  final LESSONS = 'Lessons';
  final IS_RELEASED = 'isReleased';
  final TAG = 'tag';
  final IS_BEGINNER_MODE = 'isBeginnerMode';
  final ORDER_ID = 'orderId';
  final DATE = 'date';
  final KO = 'ko';


  @override
  void initState() {
    super.initState();
    controller = Get.put(LessonStateManager());
    getDataFromDb();
  }

  getDataFromDb() {
    if (selectedToggle[0]) {
      selectedLevel == '초급'
          ? controller.futureList = Database().getDocumentsFromDb(
              collection: LESSON_COURSES,
              field: IS_BEGINNER_MODE,
              equalTo: true,
              orderBy: ORDER_ID,
              descending: false)
          : controller.futureList = Database().getDocumentsFromDb(
              collection: LESSON_COURSES,
              field: IS_BEGINNER_MODE,
              equalTo: false,
              orderBy: ORDER_ID,
              descending: false);
    } else {
      controller.futureList = Database().getDocumentsFromDb(collection: LESSONS, orderBy: DATE);
    }
  }

  updateDB({required String collection, required String docId, required Map<String, dynamic> value}) {
    Database().updateField(collection: collection, docId: docId, map: value);
    updateState();
    Get.back();
  }

  updateState() {
    setState(() {
      getDataFromDb();
    });
  }

  @override
  Widget build(BuildContext context) {
    isBeginner = selectedLevel == '초급' ? true : false;
    lessonMainDialog = LessonMainDialog(context, updateState);
    Widget getLevelRadioBtn(String value) {
      return MyRadioBtn().getRadioButton(
        context: context,
        value: value,
        groupValue: selectedLevel,
        f: (String? value) {
          selectedLevel = value!;
          updateState();
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
                        for (int i = 0; i < selectedToggle.length; i++) {
                          selectedToggle[i] = i == index;
                        }
                        updateState();
                      },
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      selectedBorderColor: Theme.of(context).colorScheme.primary,
                      selectedColor: Colors.white,
                      fillColor: Theme.of(context).colorScheme.primary,
                      color: Theme.of(context).colorScheme.primary,
                      isSelected: selectedToggle,
                      children: const [
                        Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('코스')),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('레슨')),
                      ],
                    ),
                    const SizedBox(width: 20),
                    selectedToggle[0] ? getLevelRadioBtn('초급') : const SizedBox.shrink(),
                    selectedToggle[0] ? getLevelRadioBtn('중급') : const SizedBox.shrink(),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    lessonMainDialog.openDialog(isCourse: selectedToggle[0], isBeginner: isBeginner);
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
              child: selectedToggle[0] ? courseTable() : lessonTable(),
            ),
          ],
        ),
      ),
    );
  }

  Widget courseTable() {
    return FutureBuilder(
      future: controller.futureList,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData && snapshot.connectionState != ConnectionState.waiting) {
          controller.lessonCourses = [];
          for (dynamic snapshot in snapshot.data) {
            controller.lessonCourses.add(LessonCourse.fromJson(snapshot));
          }
          List<LessonCourse> courses = controller.lessonCourses;
          if (courses.isEmpty) {
            return const Center(child: Text('검색된 코스가 없습니다.'));
          } else {
            return DataTable2(
              columns: const [
                DataColumn2(label: Text('순서'), size: ColumnSize.S),
                DataColumn2(label: Text('아이디'), size: ColumnSize.S),
                DataColumn2(label: Text('코스'), size: ColumnSize.L),
                DataColumn2(label: Text('레슨개수'), size: ColumnSize.S),
                DataColumn2(label: Text('태그'), size: ColumnSize.S),
                DataColumn2(label: Text('상태'), size: ColumnSize.S),
                DataColumn2(label: Text('순서변경'), size: ColumnSize.S),
                DataColumn2(label: Text('삭제'), size: ColumnSize.S),
              ],
              rows: List<DataRow>.generate(courses.length, (index) {
                LessonCourse course = courses[index];
                return DataRow(cells: [
                  DataCell(Text(index.toString())),
                  DataCell(Text(course.id.substring(0, 8)), onTap: () {
                    Clipboard.setData(ClipboardData(text: course.id));
                    Get.snackbar('아이디가 클립보드에 저장되었습니다.', course.id, snackPosition: SnackPosition.BOTTOM);
                  }),
                  DataCell(Text(course.title[KO]!), onTap: () {
                    lessonMainDialog.openDialog(
                        isCourse: true, isBeginner: isBeginner, lessonCourse: course);
                  }),
                  DataCell(Text(course.lessons.length.toString()), onTap: () {
                    lessonMainDialog.openLessonListDialog(course: course);
                  }),
                  DataCell(Text(course.tag != null ? course.tag.toString() : ''), onTap: () {
                    Get.dialog(
                      AlertDialog(
                        title: const Text('태그를 입력하세요'),
                        content: MyTextField().getTextField(
                            controller: TextEditingController(text: course.tag),
                            fn: (String? value) {
                              course.tag = value!;
                            }),
                        actions: [
                          TextButton(
                              onPressed: () {
                                updateDB(
                                    collection: LESSON_COURSES,
                                    docId: course.id,
                                    value: {TAG: course.tag});
                              },
                              child: const Text('저장'))
                        ],
                      ),
                    );
                  }),
                  DataCell(Text(course.isReleased ? '게시중' : '입력중'), onTap: () {
                    Get.dialog(AlertDialog(
                      content: const Text('상태를 변경하겠습니까?'),
                      actions: [
                        TextButton(
                            onPressed: () {
                              updateDB(
                                  collection: LESSON_COURSES,
                                  docId: course.id,
                                  value: {IS_RELEASED: true});
                            },
                            child: const Text('게시중')),
                        TextButton(
                            onPressed: () {
                              updateDB(
                                  collection: LESSON_COURSES,
                                  docId: course.id,
                                  value: {IS_RELEASED: false});
                            },
                            child: const Text('입력중')),
                      ],
                    ));
                  }),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                            onPressed: () async {
                              if (index != 0) {
                                int newIndex = index - 1;
                                LessonCourse thatCourse = courses[newIndex];
                                await Database().switchOrderTransaction(
                                    collection: LESSON_COURSES, docId1: course.id, docId2: thatCourse.id);
                                getDataFromDb();
                                Get.back();
                                setState(() {});
                              } else {
                                Get.dialog(const AlertDialog(
                                  title: Text('첫번째 레슨입니다.'),
                                ));
                              }
                            },
                            icon: const Icon(Icons.arrow_drop_up_outlined)),
                        IconButton(
                            onPressed: () async {
                              if (index != courses.length - 1) {
                                int newIndex = index + 1;
                                LessonCourse thatCourse = courses[newIndex];
                                await Database().switchOrderTransaction(
                                    collection: LESSON_COURSES, docId1: course.id, docId2: thatCourse.id);
                                getDataFromDb();
                                Get.back();
                                setState(() {});
                              } else {
                                Get.dialog(const AlertDialog(
                                  title: Text('마지막 레슨입니다.'),
                                ));
                              }
                            },
                            icon: const Icon(Icons.arrow_drop_down_outlined)),
                      ],
                    ),
                  ),
                  DataCell(
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        Get.dialog(AlertDialog(
                          title: const Text('정말 삭제하겠습니까?'),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    Database()
                                        .deleteLessonFromDb(collection: LESSON_COURSES, lesson: course);
                                    getDataFromDb();
                                    Get.back();
                                  });
                                },
                                child: const Text(
                                  '네',
                                  style: TextStyle(color: Colors.red),
                                )),
                            TextButton(
                                onPressed: () {
                                  Get.back();
                                },
                                child: const Text('아니오')),
                          ],
                        ));
                      },
                    ),
                  )
                ]);
              }),
            );
          }
        } else if (snapshot.hasError) {
          return Text('에러: ${snapshot.error}');
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget lessonTable() {
    return FutureBuilder(
      future: controller.futureList,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData && snapshot.connectionState != ConnectionState.waiting) {
          controller.lessons = [];
          for (dynamic snapshot in snapshot.data) {
            controller.lessons.add(Lesson.fromJson(snapshot));
          }
          List<Lesson> lessons = controller.lessons;
          if (lessons.isEmpty) {
            return const Center(child: Text('검색된 레슨이 없습니다.'));
          } else {
            return DataTable2(
              columns: const [
                DataColumn2(label: Text('아이디'), size: ColumnSize.S),
                DataColumn2(label: Text('제목'), size: ColumnSize.L),
                DataColumn2(label: Text('문법'), size: ColumnSize.L),
                DataColumn2(label: Text('쓰기'), size: ColumnSize.S),
                DataColumn2(label: Text('무료'), size: ColumnSize.S),
                DataColumn2(label: Text('상태'), size: ColumnSize.S),
                DataColumn2(label: Text('태그'), size: ColumnSize.S),
                DataColumn2(label: Text('삭제'), size: ColumnSize.S),
                DataColumn2(label: Text('레슨카드'), size: ColumnSize.S),
              ],
              rows: List<DataRow>.generate(lessons.length, (index) {
                Lesson lesson = lessons[index];
                return DataRow(cells: [
                  DataCell(Text(lesson.id.substring(0, 8)), onTap: () {
                    Clipboard.setData(ClipboardData(text: lesson.id));
                    Get.snackbar('아이디가 클립보드에 저장되었습니다.', lesson.id, snackPosition: SnackPosition.BOTTOM);
                  }),
                  DataCell(Text(lesson.title[KO]!), onTap: () {
                    lessonMainDialog.openDialog(isCourse: false, lesson: lesson);
                  }),
                  DataCell(Text(lesson.titleGrammar)),
                  DataCell(Text(lesson.writingTitles.length.toString())),
                  DataCell(Text(lesson.isFree ? 'O' : 'X')),
                  DataCell(Text(lesson.isReleased ? '게시중' : '입력중'), onTap: () {
                    Get.dialog(AlertDialog(
                      content: const Text('상태를 변경하겠습니까?'),
                      actions: [
                        TextButton(
                            onPressed: () {
                              updateDB(collection: LESSONS, docId: lesson.id, value: {IS_RELEASED: true});
                            },
                            child: const Text('게시중')),
                        TextButton(
                            onPressed: () {
                              updateDB(collection: LESSONS, docId: lesson.id, value: {IS_RELEASED: false});
                            },
                            child: const Text('입력중')),
                      ],
                    ));
                  }),
                  DataCell(Text(lesson.tag != null ? lesson.tag.toString() : ''), onTap: () {
                    Get.dialog(
                      AlertDialog(
                        title: const Text('태그를 입력하세요'),
                        content: MyTextField().getTextField(fn: (String? value) {
                          lesson.tag = value!;
                        }),
                        actions: [
                          TextButton(
                              onPressed: () {
                                updateDB(collection: LESSONS, docId: lesson.id, value: {TAG: lesson.tag});
                              },
                              child: const Text('저장'))
                        ],
                      ),
                    );
                  }),
                  DataCell(
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        Get.dialog(AlertDialog(
                          title: const Text('정말 삭제하겠습니까?'),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    Database().deleteLessonFromDb(collection: LESSONS, lesson: lesson);
                                    getDataFromDb();
                                    Get.back();
                                  });
                                },
                                child: const Text(
                                  '네',
                                  style: TextStyle(color: Colors.red),
                                )),
                            TextButton(
                                onPressed: () {
                                  Get.back();
                                },
                                child: const Text('아니오')),
                          ],
                        ));
                      },
                    ),
                  ),
                  DataCell(ElevatedButton(
                    child: const Text('보기'),
                    onPressed: () {
                      Get.to(const LessonCardMain(), arguments: lesson);
                    },
                  )),
                ]);
              }),
            );
          }
        } else if (snapshot.hasError) {
          return Text('에러: ${snapshot.error}');
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
