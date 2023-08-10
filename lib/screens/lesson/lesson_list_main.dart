import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/common/languages.dart';
import 'package:podo_admin/common/my_radio_btn.dart';
import 'package:podo_admin/common/my_textfield.dart';
import 'package:podo_admin/screens/lesson/inner_card_textfield.dart';
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
  late Map<String, TextEditingController> controllersTitle;
  LessonStateManager controller = Get.find<LessonStateManager>();
  LessonCourse course = Get.arguments;
  List<bool> typeToggle = [true, false];
  final KO = 'ko';
  final FO = 'fo';
  final ID = 'id';
  final LESSON_COURSES = 'LessonCourses';
  final LESSONS = 'lessons';
  final LESSON_COLLECTION = 'Lessons';
  final TYPE_LESSON = 'Lesson';
  final TYPE_REVIEW = 'Review';

  initDialog() {
    controllersTitle = {};
    controllersTitle = {
      ID: TextEditingController(),
      KO: TextEditingController(),
      FO: TextEditingController(),
    };
    controller.selectedLanguage = Languages().getFos[0];
    typeToggle = [true, false];
  }

  Widget getLanguageRadio(String lang) {
    return MyRadioBtn().getRadioButton(
        context: context,
        value: lang,
        groupValue: controller.selectedLanguage,
        f: (String? value) {
          controller.selectedLanguage = value!;
          controller.update();
        });
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
    typeToggle[1] = lesson.type == TYPE_REVIEW;

    Get.dialog(AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [const Text('레슨타이틀'), IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close))],
      ),
      content: GetBuilder<LessonStateManager>(
        builder: (_) {
          String selectedLanguage = controller.selectedLanguage;
          controllersTitle[ID]!.text = lesson.id ?? '';
          controllersTitle[KO]!.text = lesson.title[KO] ?? '';
          controllersTitle[FO]!.text = lesson.title[selectedLanguage] ?? '';
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('언어선택', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    getLanguageRadio('en'),
                    getLanguageRadio('es'),
                    getLanguageRadio('fr'),
                    getLanguageRadio('de'),
                    getLanguageRadio('pt'),
                    getLanguageRadio('id'),
                    getLanguageRadio('ru'),
                  ],
                ),
                const Divider(height: 80),
                Expanded(
                  child: SizedBox(
                    width: 1000,
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
                                index == 0 ? lesson.type = TYPE_LESSON : lesson.type = TYPE_REVIEW;
                                controller.update();
                              },
                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                              children: [
                                Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10), child: Text(TYPE_LESSON)),
                                Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10), child: Text(TYPE_REVIEW)),
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
                                  controllersTitle[ID]!.text = '';
                                  lesson.id = '';
                                },
                                child: const Text('기존레슨 연결')),
                          ],
                        ),
                        const SizedBox(height: 20),
                        MyTextField().getTextField(
                            controller: controllersTitle[ID],
                            label: '레슨아이디',
                            fn: (String? value) {
                              lesson.id = value!;
                            }),
                        const SizedBox(height: 20),
                        const Text('레슨타이틀', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                                child: MyTextField().getTextField(
                                    controller: controllersTitle[KO],
                                    label: '한국어',
                                    fn: (String? value) {
                                      lesson.title[KO] = value!;
                                    })),
                            const SizedBox(width: 20),
                            course.isBeginnerMode
                                ? Expanded(
                                    child: MyTextField().getTextField(
                                        controller: controllersTitle[FO],
                                        label: '외국어',
                                        fn: (String? value) {
                                          lesson.title[controller.selectedLanguage] = value!;
                                        }))
                                : const SizedBox.shrink(),
                          ],
                        ),
                        const SizedBox(height: 50),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              if (lesson.title.isNotEmpty) {
                                if (isEditMode) {
                                  course.lessons[index!] = lesson.toJson();
                                } else {
                                  course.lessons.add(lesson.toJson());
                                }
                                updateLessons();
                                Database().setEmptyDoc(collection: LESSON_COLLECTION, docId: lesson.id);
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
              ],
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
        IconButton(
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
        IconButton(
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('레슨리스트 (${course.title[KO]} : ${course.id.substring(0, 8)})')),
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
                    DataColumn2(label: Text('타이틀'), size: ColumnSize.L),
                    DataColumn2(label: Text('상태'), size: ColumnSize.S),
                    DataColumn2(label: Text('태그'), size: ColumnSize.S),
                    DataColumn2(label: Text('순서변경'), size: ColumnSize.S),
                    DataColumn2(label: Text('삭제'), size: ColumnSize.S),
                    DataColumn2(label: Text('레슨입력'), size: ColumnSize.S),
                  ],
                  rows: List<DataRow>.generate(course.lessons.length, (index) {
                    if (course.lessons[index] is Map) {
                      Lesson lesson = Lesson.fromJson(course.lessons[index]);
                      return DataRow(cells: [
                        DataCell(Text(index.toString())),
                        DataCell(Text(lesson.id.substring(0, 8)), onTap: () {
                          Clipboard.setData(ClipboardData(text: lesson.id));
                          Get.snackbar('아이디가 클립보드에 저장되었습니다.', lesson.id, snackPosition: SnackPosition.BOTTOM);
                        }),
                        DataCell(Text(lesson.type)),
                        DataCell(Text(lesson.title[KO]), onTap: () {
                          lessonDialog(index: index);
                        }),
                        DataCell(Text(lesson.isReleased ? '게시중' : '입력중'), onTap: () {
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
                            Get.to(const LessonCardMain(), arguments: lesson);
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
