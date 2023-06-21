import 'dart:io';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:podo_admin/common/cloud_storage.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/common/languages.dart';
import 'package:podo_admin/common/my_radio_btn.dart';
import 'package:podo_admin/common/my_textfield.dart';
import 'package:podo_admin/screens/lesson/lesson_course.dart';
import 'package:podo_admin/screens/lesson/lesson_list_main.dart';
import 'package:podo_admin/screens/lesson/lesson_state_manager.dart';

class LessonCourseMain extends StatefulWidget {
  LessonCourseMain({Key? key}) : super(key: key);

  @override
  State<LessonCourseMain> createState() => _LessonCourseMainState();
}

class _LessonCourseMainState extends State<LessonCourseMain> {
  late LessonStateManager controller;
  String selectedLevel = '초급';
  late bool isBeginner;
  final LESSON_COURSES = 'LessonCourses';
  final LESSONS = 'Lessons';
  final IS_RELEASED = 'isReleased';
  final TAG = 'tag';
  final IS_BEGINNER_MODE = 'isBeginnerMode';
  final ORDER_ID = 'orderId';
  final DATE = 'date';
  final KO = 'ko';
  final FO = 'fo';
  final DESC = 'desc';
  late Map<String, TextEditingController> controllersCourse;

  @override
  void initState() {
    super.initState();
    controller = Get.put(LessonStateManager());
    getDataFromDb();
  }

  getDataFromDb() {
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

  initDialog() {
    controller.selectedLanguage = Languages().getFos[0];
    controllersCourse = {};
    controllersCourse = {
      KO: TextEditingController(),
      FO: TextEditingController(),
      DESC: TextEditingController()
    };
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
      groupValue: selectedLevel,
      f: (String? value) {
        selectedLevel = value!;
        updateState();
      },
    );
  }

  Future uploadImage(String courseId) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File image = (await pickedFile.readAsBytes()) as File;
      String fileName = '$courseId.jpeg';
      CloudStorage().uploadCourseImage(image: image, fileName: fileName);
    } else {
      print('No image selected.');
    }
  }

  courseDialog({LessonCourse? lessonCourse}) async {
    lessonCourse = lessonCourse ?? LessonCourse();
    initDialog();
    String title;
    isBeginner ? title = '레슨코스(초급)' : title = '레슨코스(중급)';

    String? imageUrl = await CloudStorage().getCourseImage(courseId: lessonCourse.id);

    Get.dialog(AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(title), IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close))],
      ),
      content: GetBuilder<LessonStateManager>(
        builder: (_) {
          String selectedLanguage = controller.selectedLanguage;
          controllersCourse[KO]!.text = lessonCourse!.title[KO] ?? '';
          controllersCourse[FO]!.text = lessonCourse.title[selectedLanguage] ?? '';
          controllersCourse[DESC]!.text = lessonCourse.description[selectedLanguage] ?? '';
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
                  child: Column(
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
                                  ),
                                  child: imageUrl != null
                                      ? Image.network(imageUrl, headers: const {'Access-Control-Allow-Origin': '*'})
                                      : Image.asset('assets/podo.png')),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  uploadImage(lessonCourse!.id);
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
                                    lessonCourse!.title[KO] = value!;
                                  },
                                ),
                                const SizedBox(height: 20),
                                MyTextField().getTextField(
                                  controller: controllersCourse[FO],
                                  label: '코스입력(외국어)',
                                  fn: (String? value) {
                                    lessonCourse!.title[controller.selectedLanguage] = value!;
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
                          lessonCourse!.description[controller.selectedLanguage] = value!;
                        },
                        minLine: 5,
                      ),
                      const SizedBox(height: 50),
                      ElevatedButton(
                        onPressed: () {
                          isBeginner!
                              ? lessonCourse!.isBeginnerMode = true
                              : lessonCourse!.isBeginnerMode = false;
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
              ],
            ),
          );
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    isBeginner = selectedLevel == '초급' ? true : false;

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
                    getLevelRadioBtn('초급'),
                    getLevelRadioBtn('중급'),
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
                          DataColumn2(label: Text('순서'), size: ColumnSize.S),
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
                          return DataRow(cells: [
                            DataCell(Text(index.toString())),
                            DataCell(Text(course.id.substring(0, 8)), onTap: () {
                              Clipboard.setData(ClipboardData(text: course.id));
                              Get.snackbar('아이디가 클립보드에 저장되었습니다.', course.id,
                                  snackPosition: SnackPosition.BOTTOM);
                            }),
                            DataCell(Text(course.title[KO]!), onTap: () {
                              courseDialog(lessonCourse: course);
                            }),
                            DataCell(Text(course.lessons.length.toString())),
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
                                          onPressed: () {
                                            setState(() {
                                              Database().deleteLessonFromDb(
                                                  collection: LESSON_COURSES, lesson: course);
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
