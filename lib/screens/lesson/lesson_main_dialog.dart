import 'dart:io';
import 'package:data_table_2/data_table_2.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/common/languages.dart';
import 'package:podo_admin/common/my_radio_btn.dart';
import 'package:podo_admin/common/my_textfield.dart';
import 'package:podo_admin/screens/lesson/lesson_card_main.dart';
import 'package:podo_admin/screens/lesson/lesson_state_manager.dart';
import 'package:podo_admin/screens/lesson/lesson_course.dart';
import 'package:podo_admin/screens/lesson/lesson.dart';
import 'package:podo_admin/screens/writing/writing_title.dart';

class LessonMainDialog {
  late final VoidCallback updateState;
  late final BuildContext context;
  final LESSON_COURSES = 'LessonCourses';
  final KO = 'ko';
  final FO = 'fo';
  final DESC = 'desc';
  final GRAM = 'gram';
  final LESSONS = 'Lessons';
  final ID = 'id';

  LessonMainDialog(this.context, this.updateState);

  LessonStateManager controller = Get.find<LessonStateManager>();
  late Map<String, TextEditingController> controllersCourse;
  late Map<String, TextEditingController> controllersTitle;
  late List<Map<String, dynamic>> controllersWritingTitle;
  late bool isCourse;
  bool? isBeginner;

  initDialog() {
    controller.selectedLanguage = Languages().getFos[0];
    controller.isFreeLessonChecked = true;
    controllersCourse = {};
    controllersCourse = {
      KO: TextEditingController(),
      FO: TextEditingController(),
      DESC: TextEditingController()
    };
    controllersTitle = {};
    controllersTitle = {
      KO: TextEditingController(),
      FO: TextEditingController(),
      GRAM: TextEditingController(),
    };
  }

  openDialog({required bool isCourse, bool? isBeginner, LessonCourse? lessonCourse, Lesson? lesson}) {
    this.isCourse = isCourse;
    this.isBeginner = isBeginner;
    lessonCourse = lessonCourse ?? LessonCourse();
    lesson = lesson ?? Lesson();

    initDialog();
    String title;
    Widget widget;

    if (isCourse) {
      isBeginner! ? title = '레슨코스(초급)' : title = '레슨코스(중급)';
    } else {
      title = '레슨타이틀';
    }

    Get.dialog(AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close))
        ],
      ),
      content: GetBuilder<LessonStateManager>(
        builder: (_) {
          String selectedLanguage = controller.selectedLanguage;

          if (isCourse) {
            controllersCourse[KO]!.text = lessonCourse!.title[KO] ?? '';
            controllersCourse[FO]!.text = lessonCourse.title[selectedLanguage] ?? '';
            controllersCourse[DESC]!.text = lessonCourse.description[selectedLanguage] ?? '';
            widget = getSubjectDialog(lessonCourse);
          } else {
            controllersTitle[KO]!.text = lesson!.title[KO] ?? '';
            controllersTitle[FO]!.text = lesson.title[selectedLanguage] ?? '';
            controllersTitle[GRAM]!.text = lesson.titleGrammar;

            controllersWritingTitle = [];
            if (lesson.writingTitles.isNotEmpty) {
              for (int i = 0; i < lesson.writingTitles.length; i++) {
                controllersWritingTitle.add({KO: TextEditingController(), FO: TextEditingController()});
                controllersWritingTitle[i][KO]!.text = lesson.writingTitles[i].title[KO] ?? '';
                controllersWritingTitle[i][FO]!.text =
                    lesson.writingTitles[i].title[selectedLanguage] ?? '';
              }
            }
            widget = getTitleDialog(lesson);
          }
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
                Expanded(child: widget),
              ],
            ),
          );
        },
      ),
    ));
  }

  Widget getSubjectDialog(LessonCourse lessonCourse) {
    File image;
    final picker = ImagePicker();
    FirebaseStorage storage = FirebaseStorage.instance;

    Future getImage() async {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        image = File(pickedFile.path);
        String fileName = '${lessonCourse.id.toString()}.jpeg';
        try {
          final ref = storage.ref().child('LessonCourseImages/$fileName');
          ref.putFile((await image.readAsBytes()) as File);
        } catch (e) {
          print('Storage error: $e');
        }
      } else {
        print('No image selected.');
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Column(
              children: [
                Container(
                  width: 130.0,
                  height: 130.0,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                          "https://www.helpguide.org/wp-content/uploads/king-charles-spaniel-resting-head.jpg"),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    getImage();
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text('이미지 업로드'),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 50),
            Expanded(
              child: Column(
                children: [
                  MyTextField().getTextField(
                    controller: controllersCourse[KO],
                    label: '코스입력(한국어)',
                    fn: (String? value) {
                      lessonCourse.title[KO] = value!;
                    },
                  ),
                  const SizedBox(height: 20),
                  MyTextField().getTextField(
                    controller: controllersCourse[FO],
                    label: '코스입력(외국어)',
                    fn: (String? value) {
                      lessonCourse.title[controller.selectedLanguage] = value!;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 50),
        MyTextField().getTextField(
          controller: controllersCourse[DESC],
          label: '설명',
          fn: (String? value) {
            lessonCourse.description[controller.selectedLanguage] = value!;
          },
          minLine: 5,
        ),
        const SizedBox(height: 50),
        ElevatedButton(
          onPressed: () {
            isBeginner! ? lessonCourse.isBeginnerMode = true : lessonCourse.isBeginnerMode = false;
            Database().setDoc(collection: LESSON_COURSES, doc: lessonCourse);
            Get.back();
            updateState();
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text('저장', style: TextStyle(fontSize: 20)),
          ),
        ),
      ],
    );
  }

  Widget getTitleDialog(Lesson lesson) {
    return SizedBox(
      width: 1000,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              Expanded(
                  child: MyTextField().getTextField(
                      controller: controllersTitle[FO],
                      label: '외국어',
                      fn: (String? value) {
                        lesson.title[controller.selectedLanguage] = value!;
                      })),
              const SizedBox(width: 20),
              Expanded(
                  child: MyTextField().getTextField(
                      controller: controllersTitle[GRAM],
                      label: '문법',
                      fn: (String? value) {
                        lesson.titleGrammar = value!;
                      })),
              const SizedBox(width: 20),
              Column(
                children: [
                  const Text('무료'),
                  Checkbox(
                      value: controller.isFreeLessonChecked,
                      onChanged: (value) {
                        controller.isFreeLessonChecked = value!;
                        lesson.isFree = value!;
                        controller.update();
                      }),
                ],
              )
            ],
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              const Text('쓰기타이틀', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(width: 20),
              IconButton(
                  onPressed: () {
                    lesson.writingTitles.add(WritingTitle());
                    controllersWritingTitle
                        .add({KO: TextEditingController(), FO: TextEditingController()});
                    controller.update();
                  },
                  icon: Icon(Icons.add_circle_outline_rounded,
                      size: 30, color: Theme.of(context).colorScheme.primary)),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: controllersWritingTitle.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: controllersWritingTitle.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            Expanded(
                                child: MyTextField().getTextField(
                                    controller: controllersWritingTitle[index][KO],
                                    label: '한국어',
                                    fn: (String? value) {
                                      lesson.writingTitles[index].title[KO] = value!;
                                    })),
                            const SizedBox(width: 20),
                            Expanded(
                                child: MyTextField().getTextField(
                                    controller: controllersWritingTitle[index][FO],
                                    label: '외국어',
                                    fn: (String? value) {
                                      lesson.writingTitles[index].title[controller.selectedLanguage] = value!;
                                    })),
                            const SizedBox(width: 20),
                            DropdownButton(
                                value: controller.writingLevel[lesson.writingTitles[index].level],
                                icon: const Icon(Icons.arrow_drop_down_outlined),
                                items: controller.writingLevel.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem(value: value, child: Text(value));
                                }).toList(),
                                onChanged: (value) {
                                  lesson.writingTitles[index].level =
                                      controller.writingLevel.indexOf(value.toString());
                                  controller.update();
                                }),
                            const SizedBox(width: 20),
                            Column(
                              children: [
                                const Text('무료'),
                                Checkbox(
                                    value: lesson.writingTitles[index].isFree,
                                    onChanged: (value) {
                                      lesson.writingTitles[index].isFree = value!;
                                      controller.update();
                                    }),
                              ],
                            ),
                            const SizedBox(width: 30),
                            IconButton(
                                onPressed: () {
                                  lesson.writingTitles.removeAt(index);
                                  controllersWritingTitle.removeAt(index);
                                  controller.update();
                                },
                                icon: const Icon(
                                  Icons.remove_circle_outline_rounded,
                                  size: 30,
                                  color: Colors.red,
                                )),
                          ],
                        ),
                      );
                    },
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 50),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Database().setDoc(collection: LESSONS, doc: lesson);
                Get.back();
                updateState();
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text('저장', style: TextStyle(fontSize: 20)),
              ),
            ),
          ),
        ],
      ),
    );
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

  openLessonListDialog({required LessonCourse course}) {
    String lessonId = '';
    Get.dialog(AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(course.title[KO]),
          ElevatedButton(
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: const Text('레슨 아이디를 입력하세요'),
                  content: MyTextField().getTextField(fn: (String? value) {
                    lessonId = value!;
                  }),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Get.back();
                          if (course.lessons.contains(lessonId)) {
                            Get.dialog(const AlertDialog(
                              title: Text('이미 포함된 레슨 입니다.'),
                            ));
                          } else {
                            Database().addValueTransaction(
                              collection: LESSON_COURSES,
                              docId: course.id,
                              field: 'lessons',
                              addValue: lessonId,
                            );
                            course.lessons.add(lessonId);
                          }
                        },
                        child: const Text('저장'))
                  ],
                ),
              );
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
      content: GetBuilder<LessonStateManager>(
        builder: (controller) {
          final list = List.from(course.lessons);
          final quotient = (list.length.toDouble() / 10).floor();
          final remainder = list.length % 10;

          List<Future> futures = [];

          for (int i = 0; i < quotient; i++) {
            futures.add(
                Database().getDocsFromList(collection: LESSONS, field: ID, list: list.sublist(0, 10)));
            list.removeRange(0, 10);
          }

          if (remainder != 0) {
            futures.add(Database().getDocsFromList(collection: LESSONS, field: ID, list: list));
          }

          controller.futureList = Future.wait(futures);

          return SizedBox(
            width: 1500,
            child: FutureBuilder(
                future: controller.futureList,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData && snapshot.connectionState != ConnectionState.waiting) {
                    List<Lesson> lessons = [];
                    for (dynamic snapshot in snapshot.data) {
                      for (dynamic s in snapshot) {
                        lessons.add(Lesson.fromJson(s));
                      }
                    }
                    if (lessons.isEmpty) {
                      return const Center(child: Text('연결된 타이틀이 없습니다.'));
                    } else {
                      // 타이틀 순서 정렬
                      Lesson temp;
                      int length = lessons.length;
                      for (int i = 0; i < length; i++) {
                        for (int j = 0; j < length; j++) {
                          if (lessons[j].id == course.lessons[i] && i != j) {
                            temp = lessons[i];
                            lessons[i] = lessons[j];
                            lessons[j] = temp;
                          }
                        }
                      }

                      return DataTable2(
                          columns: const [
                            DataColumn2(label: Text('순서'), size: ColumnSize.S),
                            DataColumn2(label: Text('레슨아이디'), size: ColumnSize.L),
                            DataColumn2(label: Text('타이틀'), size: ColumnSize.L),
                            DataColumn2(label: Text('상태'), size: ColumnSize.S),
                            DataColumn2(label: Text('순서변경'), size: ColumnSize.S),
                            DataColumn2(label: Text('삭제'), size: ColumnSize.S),
                          ],
                          rows: List<DataRow>.generate(lessons.length, (index) {
                            Lesson lesson = lessons[index];
                            return DataRow(cells: [
                              DataCell(Text(index.toString())),
                              DataCell(Text(lesson.id), onTap: () {
                                Get.to(const LessonCardMain(), arguments: lesson);
                              }),
                              DataCell(Text(lesson.title[KO])),
                              DataCell(Text(lesson.isReleased ? '게시중' : '입력중')),
                              DataCell(Row(
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        if (index != 0) {
                                          List<dynamic> lessons = course.lessons;
                                          int newIndex = index - 1;
                                          final temp = lessons[newIndex];
                                          lessons[newIndex] = lessons[index];
                                          lessons[index] = temp;
                                          Database().updateField(
                                              collection: LESSON_COURSES,
                                              docId: course.id,
                                              map: {'lessons': lessons});
                                          controller.update();
                                        } else {
                                          Get.dialog(const AlertDialog(
                                            title: Text('첫번째 레슨입니다.'),
                                          ));
                                        }
                                      },
                                      icon: const Icon(Icons.arrow_drop_up_outlined)),
                                  IconButton(
                                      onPressed: () {
                                        if (index != course.lessons.length - 1) {
                                          List<dynamic> lessons = course.lessons;
                                          int newIndex = index + 1;
                                          final temp = lessons[newIndex];
                                          lessons[newIndex] = lessons[index];
                                          lessons[index] = temp;
                                          Database().updateField(
                                              collection: LESSON_COURSES,
                                              docId: course.id,
                                              map: {'lessons': lessons});
                                          controller.update();
                                        } else {
                                          Get.dialog(const AlertDialog(
                                            title: Text('마지막 레슨입니다.'),
                                          ));
                                        }
                                      },
                                      icon: const Icon(Icons.arrow_drop_down_outlined)),
                                ],
                              )),
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
                                              course.lessons.removeAt(index);
                                              Database().updateField(
                                                  collection: LESSON_COURSES,
                                                  docId: course.id,
                                                  map: {'lessons': course.lessons});
                                              Get.back();
                                              controller.update();
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
                          }));
                    }
                  } else if (snapshot.hasError) {
                    return Text('에러: ${snapshot.error}');
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                }),
          );
        },
      ),
    ));
  }
}
