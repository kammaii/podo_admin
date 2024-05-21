import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/common/deepl_translator.dart';
import 'package:podo_admin/common/languages.dart';
import 'package:podo_admin/common/my_textfield.dart';
import 'package:podo_admin/screens/lesson/lesson.dart';
import 'package:podo_admin/screens/lesson/lesson_card_main.dart';
import 'package:podo_admin/screens/lesson/lesson_course.dart';
import 'package:podo_admin/screens/lesson/lesson_state_manager.dart';

class LessonListMain extends StatefulWidget {
  const LessonListMain({Key? key}) : super(key: key);

  @override
  State<LessonListMain> createState() => _LessonListMainState();
}

class _LessonListMainState extends State<LessonListMain> {
  LessonStateManager controller = Get.find<LessonStateManager>();
  LessonCourse course = Get.arguments;
  List<bool> typeToggle = [true, false];
  List<bool> optionsToggle = [true, false];
  List<bool> isFreeToggle = [true, false];
  List<bool> isFreeOptionToggle = [true, false];
  final KO = 'ko';
  final LESSON_COURSES = 'LessonCourses';
  final LESSONS = 'lessons';
  final LESSON_COLLECTION = 'Lessons';
  final TYPE_LESSON = 'Lesson';
  final TYPE_PRACTICE = 'Practice';

  initDialog() {
    controller.selectedLanguage = Languages().getFos[0];
    typeToggle = [true, false];
    optionsToggle = [true, false];
  }

  Widget getLessonTitleField(Lesson lesson) {
    List<Widget> widgets = [];
    widgets.add(MyTextField().getTextField(
        controller: TextEditingController(text: lesson.title[KO]),
        label: KO,
        fn: (String? value) {
          lesson.title[KO] = value!;
        }));
    if (course.isTopicMode) {
      for (String fo in Languages().getFos) {
        Widget widget = Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: MyTextField().getTextField(
              controller: TextEditingController(text: lesson.title[fo]),
              label: fo,
              fn: (String? value) {
                lesson.title[fo] = value!;
              }),
        );
        widgets.add(widget);
      }
    }
    return Column(
      children: widgets,
    );
  }

  lessonDialog({int? index}) {
    bool isEditMode;
    Lesson lesson;
    if (index == null) {
      isEditMode = false;
      lesson = Lesson();
    } else {
      isEditMode = true;
      lesson = Lesson.fromJson(course.lessons[index]);
    }
    initDialog();
    typeToggle[0] = lesson.type == TYPE_LESSON;
    typeToggle[1] = lesson.type == TYPE_PRACTICE;
    optionsToggle[0] = lesson.hasOptions == true;
    optionsToggle[1] = lesson.hasOptions == false;
    isFreeToggle[0] = lesson.isFree == true;
    isFreeToggle[1] = lesson.isFree == false;
    isFreeOptionToggle[0] = lesson.isFreeOptions == true;
    isFreeOptionToggle[1] = lesson.isFreeOptions == false;

    Get.dialog(AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [const Text('레슨타이틀'), IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close))],
      ),
      content: GetBuilder<LessonStateManager>(
        builder: (_) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: 1000,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('타입', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 20),
                        ToggleButtons(
                          isSelected: typeToggle,
                          onPressed: (int index) {
                            typeToggle[0] = index == 0;
                            typeToggle[1] = index == 1;
                            if (index == 1) {
                              lesson.type = TYPE_PRACTICE;
                              lesson.hasOptions = false;
                              optionsToggle[0] = false;
                              optionsToggle[1] = true;
                              lesson.isFree = false;
                              isFreeToggle[0] = false;
                              isFreeToggle[1] = true;
                            } else {
                              lesson.type = TYPE_LESSON;
                            }
                            controller.update();
                          },
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                          children: [
                            Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text(TYPE_LESSON)),
                            Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10), child: Text(TYPE_PRACTICE)),
                          ],
                        ),
                        const SizedBox(width: 20),
                        const Text('요약/쓰기 유무', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 20),
                        ToggleButtons(
                          isSelected: optionsToggle,
                          onPressed: (int index) {
                            optionsToggle[0] = index == 0;
                            optionsToggle[1] = index == 1;
                            index == 0 ? lesson.hasOptions = true : lesson.hasOptions = false;
                            controller.update();
                          },
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                          children: const [
                            Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('있음')),
                            Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('없음')),
                          ],
                        ),
                        const SizedBox(width: 20),
                        const Text('레슨무료', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 20),
                        ToggleButtons(
                          isSelected: isFreeToggle,
                          onPressed: (int index) {
                            isFreeToggle[0] = index == 0;
                            isFreeToggle[1] = index == 1;
                            index == 0 ? lesson.isFree = true : lesson.isFree = false;
                            controller.update();
                          },
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                          children: const [
                            Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('O')),
                            Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('X')),
                          ],
                        ),
                        const SizedBox(width: 20),
                        const Text('옵션무료', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 20),
                        ToggleButtons(
                          isSelected: isFreeOptionToggle,
                          onPressed: (int index) async {
                            isFreeOptionToggle[0] = index == 0;
                            isFreeOptionToggle[1] = index == 1;
                            index == 0 ? lesson.isFreeOptions = true : lesson.isFreeOptions = false;
                            controller.update();
                          },
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                          children: const [
                            Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('O')),
                            Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('X')),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text('레슨아이디', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 10),
                        TextButton(
                            onPressed: () {
                              lesson.id = '';
                              controller.update();
                            },
                            child: const Text('기존레슨 연결')),
                      ],
                    ),
                    const SizedBox(height: 20),
                    MyTextField().getTextField(
                        controller: TextEditingController(text: lesson.id ?? ''),
                        label: '레슨아이디',
                        fn: (String? value) {
                          lesson.id = value!;
                        }),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text('레슨타이틀', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 10),
                        DeeplTranslator().getTransBtn(controller, lesson.title),
                      ],
                    ),
                    const SizedBox(height: 20),
                    getLessonTitleField(lesson),
                    const SizedBox(height: 50),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (lesson.title.isNotEmpty) {
                            if (lesson.readingId != null) {
                              Database().updateField(
                                  collection: 'ReadingTitles',
                                  docId: lesson.readingId!,
                                  map: {'isFree': lesson.isFreeOptions});
                            }
                            if (lesson.speakingId != null) {
                              Database().updateField(
                                  collection: 'SpeakingTitles',
                                  docId: lesson.speakingId!,
                                  map: {'isFree': lesson.isFreeOptions});
                            }

                            if (isEditMode) {
                              course.lessons[index!] = lesson.toJson();
                            } else {
                              course.lessons.add(lesson.toJson());
                            }
                            updateLessons();
                            Database().setLessonTitle(collection: LESSON_COLLECTION, docId: lesson.id);
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Text('저장', style: TextStyle(fontSize: 20)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ));
  }

  updateLessons({bool shouldBack = true}) {
    setState(() {
      if (shouldBack) {
        Get.back();
      }
      Database().updateField(collection: LESSON_COURSES, docId: course.id, map: {LESSONS: course.lessons});
    });
  }

  Widget _orderArrow(int index) {
    return Row(
      children: [
        Expanded(
          child: IconButton(
              onPressed: () {
                if (index != 0) {
                  int newIndex = index - 1;
                  final lesson1 = course.lessons[index];
                  final lesson2 = course.lessons[newIndex];
                  course.lessons[index] = lesson2;
                  course.lessons[newIndex] = lesson1;
                  updateLessons(shouldBack: false);
                } else {
                  Get.dialog(const AlertDialog(
                    title: Text('첫번째 레슨입니다.'),
                  ));
                }
              },
              icon: const Icon(Icons.arrow_drop_up_outlined)),
        ),
        Expanded(
          child: IconButton(
              onPressed: () {
                if (index != course.lessons.length + 1) {
                  int newIndex = index + 1;
                  final lesson1 = course.lessons[index];
                  final lesson2 = course.lessons[newIndex];
                  course.lessons[index] = lesson2;
                  course.lessons[newIndex] = lesson1;
                  updateLessons(shouldBack: false);
                } else {
                  Get.dialog(const AlertDialog(
                    title: Text('마지막 레슨입니다.'),
                  ));
                }
              },
              icon: const Icon(Icons.arrow_drop_down_outlined)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('레슨리스트 (${course.title['en']} : ${course.id.substring(0, 8)})')),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: () {
                    String category = '';
                    Get.dialog(
                      AlertDialog(
                        title: const Text('카테고리를 입력하세요'),
                        content: MyTextField().getTextField(fn: (String? value) {
                          category = value!;
                        }),
                        actions: [
                          TextButton(
                              onPressed: () {
                                course.lessons.add(category);
                                updateLessons();
                              },
                              child: const Text('추가'))
                        ],
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text('카테고리추가', style: TextStyle(fontSize: 20)),
                  )),
              ElevatedButton(
                  onPressed: () {
                    lessonDialog();
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text('레슨추가', style: TextStyle(fontSize: 20)),
                  )),
            ],
          ),
          Expanded(child: GetBuilder<LessonStateManager>(builder: (controller) {
            if (course.lessons.isEmpty) {
              return const Center(child: Text('연결된 레슨이 없습니다.'));
            } else {
              return DataTable2(
                  columns: const [
                    DataColumn2(label: Text('순서'), size: ColumnSize.S),
                    DataColumn2(label: Text('아이디'), size: ColumnSize.S),
                    DataColumn2(label: Text('타입'), size: ColumnSize.S),
                    DataColumn2(label: Text('레슨무료'), size: ColumnSize.S),
                    DataColumn2(label: Text('옵션'), size: ColumnSize.S),
                    DataColumn2(label: Text('옵션무료'), size: ColumnSize.S),
                    DataColumn2(label: Text('타이틀'), size: ColumnSize.L),
                    DataColumn2(label: Text('상태'), size: ColumnSize.S),
                    DataColumn2(label: Text('태그'), size: ColumnSize.S),
                    DataColumn2(label: Text('순서변경'), size: ColumnSize.S),
                    DataColumn2(label: Text('삭제'), size: ColumnSize.S),
                    DataColumn2(label: Text('레슨입력'), size: ColumnSize.S),
                  ],
                  rows: List<DataRow>.generate(course.lessons.length, (i) {
                    int index = course.lessons.length - 1 - i;
                    if (course.lessons[index] is Map) {
                      Lesson lesson = Lesson.fromJson(course.lessons[index]);
                      List<Widget> optionsIcon = [];
                      if (lesson.hasOptions) {
                        optionsIcon.add(const Icon(CupertinoIcons.pen, color: Colors.deepPurpleAccent));
                      }
                      if (lesson.readingId != null) {
                        Color iconColor = lesson.isReadingReleased! ? Colors.deepPurpleAccent : Colors.grey;
                        optionsIcon.add(
                            GestureDetector(onTap: () {
                              String titleMsg = lesson.isReadingReleased! ? '읽기를 비공개 하겠습니까?' : '읽기를 공개하겠습니까?';
                              Get.dialog(AlertDialog(
                                title: Text(titleMsg),
                                actions: [
                                  TextButton(onPressed: (){
                                    Get.back();
                                  }, child: const Text('아니오')),
                                  TextButton(onPressed: (){
                                    lesson.isReadingReleased = !lesson.isReadingReleased!;
                                    course.lessons[index] = lesson.toJson();
                                    updateLessons();
                                    Database().updateField(collection: 'ReadingTitles', docId: lesson.readingId!, map: {'isReleased': lesson.isReadingReleased});
                                  }, child: const Text('네')),
                                ],
                              ));
                            }, child: Icon(CupertinoIcons.book, color: iconColor)));
                      }
                      if (lesson.speakingId != null) {
                        Color iconColor = lesson.isSpeakingReleased! ? Colors.deepPurpleAccent : Colors.grey;
                        optionsIcon.add(Icon(CupertinoIcons.text_bubble, color: iconColor));
                      }
                      return DataRow(cells: [
                        DataCell(Text(index.toString())),
                        DataCell(Text(lesson.id.substring(0, 8)), onTap: () {
                          Clipboard.setData(ClipboardData(text: lesson.id));
                          Get.snackbar('아이디가 클립보드에 저장되었습니다.', lesson.id, snackPosition: SnackPosition.BOTTOM);
                        }),
                        DataCell(Text(lesson.type)),
                        DataCell(Text(lesson.isFree ? 'O' : 'X')),
                        DataCell(Row(children: optionsIcon)),
                        DataCell(Text(lesson.isFreeOptions != null && lesson.isFreeOptions! ? 'O' : 'X')),
                        DataCell(Text(lesson.title[KO]), onTap: () {
                          lessonDialog(index: index);
                        }),
                        DataCell(Icon(Icons.circle, color: lesson.isReleased ? Colors.green : Colors.red),
                            onTap: () {
                          Get.dialog(AlertDialog(
                            content: const Text('상태를 변경하겠습니까?'),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    lesson.isReleased = true;
                                    course.lessons[index] = lesson.toJson();
                                    updateLessons();
                                  },
                                  child: const Text('게시중')),
                              TextButton(
                                  onPressed: () {
                                    lesson.isReleased = false;
                                    course.lessons[index] = lesson.toJson();
                                    updateLessons();
                                  },
                                  child: const Text('입력중')),
                            ],
                          ));
                        }),
                        DataCell(Text(lesson.tag != null ? lesson.tag.toString() : ''), onTap: () {
                          Get.dialog(
                            AlertDialog(
                              title: const Text('태그를 입력하세요'),
                              content: MyTextField().getTextField(
                                  controller: TextEditingController(text: lesson.tag),
                                  fn: (String? value) {
                                    lesson.tag = value!;
                                  }),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      course.lessons[index] = lesson.toJson();
                                      updateLessons();
                                    },
                                    child: const Text('저장'))
                              ],
                            ),
                          );
                        }),
                        DataCell(_orderArrow(index)),
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
                                        Database().deleteDoc(collection: LESSON_COLLECTION, doc: lesson);
                                        course.lessons.removeAt(index);
                                        updateLessons();
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
                            Get.to(const LessonCardMain(), arguments: {'course': course, 'index': index});
                          },
                        )),
                      ]);
                    } else {
                      String category = course.lessons[index];
                      return DataRow(
                          cells: List<DataCell>.generate(9, (idx) {
                        if (idx == 0) {
                          return DataCell(Text(index.toString()));
                        } else if (idx == 3) {
                          return DataCell(Text(category), onTap: () {
                            Get.dialog(
                              AlertDialog(
                                title: const Text('카테고리를 입력하세요'),
                                content: MyTextField().getTextField(
                                    controller: TextEditingController(text: category),
                                    fn: (String? value) {
                                      category = value!;
                                    }),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        course.lessons[index] = category;
                                        updateLessons();
                                      },
                                      child: const Text('저장'))
                                ],
                              ),
                            );
                          });
                        } else if (idx == 6) {
                          return DataCell(_orderArrow(index));
                        } else if (idx == 8) {
                          return DataCell(
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
                                          course.lessons.removeAt(index);
                                          updateLessons();
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
                          );
                        } else {
                          return const DataCell(SizedBox.shrink());
                        }
                      }));
                    }
                  }));
            }
          })),
        ]),
      ),
    );
  }
}
