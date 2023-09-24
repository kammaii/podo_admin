import 'dart:convert';
import 'dart:io';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/common/gpt_translator.dart';
import 'package:podo_admin/common/languages.dart';
import 'package:podo_admin/common/my_radio_btn.dart';
import 'package:podo_admin/common/my_textfield.dart';
import 'package:podo_admin/screens/lesson/lesson_course.dart';
import 'package:podo_admin/screens/lesson/lesson_list_main.dart';
import 'package:podo_admin/screens/lesson/lesson_state_manager.dart';
import 'package:file_picker/file_picker.dart';

class LessonCourseMain extends StatefulWidget {
  LessonCourseMain({Key? key}) : super(key: key);

  @override
  State<LessonCourseMain> createState() => _LessonCourseMainState();
}

class _LessonCourseMainState extends State<LessonCourseMain> {
  late LessonStateManager controller;
  String selectedMode = 'Topic';
  late bool isTopicMode;
  final LESSON_COURSES = 'LessonCourses';
  final LESSONS = 'Lessons';
  final IS_RELEASED = 'isReleased';
  final TAG = 'tag';
  final IS_TOPIC_MODE = 'isTopicMode';
  final ORDER_ID = 'orderId';
  final DATE = 'date';
  final KO = 'ko';
  final FO = 'fo';
  final DESC = 'desc';
  File? imageFile;

  @override
  void initState() {
    super.initState();
    controller = Get.put(LessonStateManager());
    getDataFromDb();
  }

  getDataFromDb() {
    selectedMode == 'Topic'
        ? controller.futureList = Database().getDocs(
            collection: LESSON_COURSES, field: IS_TOPIC_MODE, equalTo: true, orderBy: ORDER_ID, descending: false)
        : controller.futureList = Database().getDocs(
            collection: LESSON_COURSES,
            field: IS_TOPIC_MODE,
            equalTo: false,
            orderBy: ORDER_ID,
            descending: false);
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

  Widget getLevelRadioBtn(String value) {
    return MyRadioBtn().getRadioButton(
      context: context,
      value: value,
      groupValue: selectedMode,
      f: (String? value) {
        selectedMode = value!;
        updateState();
      },
    );
  }

  Future uploadImage(LessonCourse lessonCourse) async {
    final pickedFile = await FilePicker.platform.pickFiles(type: FileType.image);

    if (pickedFile != null) {
      Uint8List? imageBytes = pickedFile.files.single.bytes;
      if (imageBytes != null) {
        String base64Image = base64Encode(imageBytes);
        lessonCourse.image = base64Image;
        controller.update();
      } else {
        print('Failed to read image file.');
      }
    } else {
      print('No image selected.');
    }
  }

  Widget getTextFields(LessonCourse lessonCourse, bool isTitle) {
    List<Widget> widgets = [];
    for (String fo in Languages().getFos) {
      Widget widget = Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: MyTextField().getTextField(
            controller:
                TextEditingController(text: isTitle ? lessonCourse.title[fo] : lessonCourse.description[fo]),
            label: fo,
            fn: (String? value) {
              if (isTitle) {
                lessonCourse.title[fo] = value!;
              } else {
                lessonCourse.description[fo] = value!;
              }
            }),
      );
      widgets.add(widget);
    }
    return Column(
      children: widgets,
    );
  }

  courseDialog({LessonCourse? lessonCourse}) async {
    lessonCourse = lessonCourse ?? LessonCourse();
    String title;
    isTopicMode ? title = 'Topic Mode (${lessonCourse.id})' : title = 'Grammar Mode (${lessonCourse.id})';

    Get.dialog(AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(title), IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close))],
      ),
      content: GetBuilder<LessonStateManager>(
        builder: (_) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      lessonCourse!.image != null
                          ? Stack(
                              children: [
                                Image.memory(base64Decode(lessonCourse.image!), height: 100, width: 100),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    alignment: Alignment.topRight,
                                    padding: const EdgeInsets.all(0),
                                    icon: const Icon(Icons.remove_circle_outline_outlined),
                                    color: Colors.red,
                                    onPressed: () {
                                      lessonCourse!.image = null;
                                      controller.update();
                                    },
                                  ),
                                ),
                              ],
                            )
                          : const Icon(Icons.error),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          uploadImage(lessonCourse!);
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Text('이미지 업로드'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  Row(
                    children: [
                      const Text('타이틀', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 10),
                      TextButton(
                          onPressed: () {
                            GPTTranslator()
                                .getTranslations(lessonCourse!.title)
                                .then((value) => controller.update());
                          },
                          child: const Text('번역')),
                    ],
                  ),
                  const SizedBox(height: 10),
                  getTextFields(lessonCourse, true),
                  const SizedBox(height: 50),
                  Row(
                    children: [
                      const Text('설명', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 10),
                      TextButton(
                          onPressed: () {
                            GPTTranslator()
                                .getTranslations(lessonCourse!.description)
                                .then((value) => controller.update());
                          },
                          child: const Text('번역')),
                    ],
                  ),
                  const SizedBox(height: 10),
                  getTextFields(lessonCourse, false),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: () {
                      isTopicMode ? lessonCourse!.isTopicMode = true : lessonCourse!.isTopicMode = false;
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
              ),
            ),
          );
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    isTopicMode = selectedMode == 'Topic' ? true : false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('레슨코스'),
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
                    getLevelRadioBtn('Topic'),
                    getLevelRadioBtn('Grammar'),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    courseDialog();
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
              child: FutureBuilder(
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
                          DataColumn2(label: Text('순서ID'), size: ColumnSize.S),
                          DataColumn2(label: Text('아이디'), size: ColumnSize.S),
                          DataColumn2(label: Text('코스'), size: ColumnSize.S),
                          DataColumn2(label: Text('레슨개수'), size: ColumnSize.S),
                          DataColumn2(label: Text('태그'), size: ColumnSize.S),
                          DataColumn2(label: Text('상태'), size: ColumnSize.S),
                          DataColumn2(label: Text('순서변경'), size: ColumnSize.S),
                          DataColumn2(label: Text('삭제'), size: ColumnSize.S),
                          DataColumn2(label: Text('레슨보기'), size: ColumnSize.S),
                        ],
                        rows: List<DataRow>.generate(courses.length, (index) {
                          LessonCourse course = courses[index];
                          int lessonLength = 0;
                          for (dynamic lesson in course.lessons) {
                            if (lesson is Map) {
                              lessonLength++;
                            }
                          }
                          return DataRow(cells: [
                            DataCell(Text(course.orderId.toString())),
                            DataCell(Text(course.id.substring(0, 8)), onTap: () {
                              Clipboard.setData(ClipboardData(text: course.id));
                              Get.snackbar('아이디가 클립보드에 저장되었습니다.', course.id, snackPosition: SnackPosition.BOTTOM);
                            }),
                            DataCell(Text(course.title['en']!), onTap: () {
                              courseDialog(lessonCourse: course);
                            }),
                            DataCell(Text(lessonLength.toString())),
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
                            DataCell(Icon(Icons.circle, color: course.isReleased ? Colors.green : Colors.red),
                                onTap: () {
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
                                              collection: LESSON_COURSES,
                                              docId1: course.id,
                                              docId2: thatCourse.id);
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
                                              collection: LESSON_COURSES,
                                              docId1: course.id,
                                              docId2: thatCourse.id);
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
                                          onPressed: () async {
                                            Get.back();
                                            await Database().deleteListAndReorderBatch(
                                                collection: LESSON_COURSES, index: index, list: courses);
                                            setState(() {
                                              getDataFromDb();
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
                                onPressed: () {
                                  Get.to(const LessonListMain(), arguments: course);
                                },
                                child: const Text('보기'))),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
