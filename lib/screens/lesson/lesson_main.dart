import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/common/my_radio_btn.dart';
import 'package:podo_admin/screens/lesson/lesson_state_manager.dart';
import 'package:podo_admin/screens/lesson/lesson_subject.dart';
import 'package:podo_admin/screens/lesson/lesson_subject_main.dart';
import 'package:podo_admin/screens/lesson/lesson_title.dart';
import 'package:podo_admin/screens/lesson/lesson_title_main.dart';
import 'package:podo_admin/screens/writing/writing_title.dart';

class LessonMain extends StatefulWidget {
  LessonMain({Key? key}) : super(key: key);

  @override
  State<LessonMain> createState() => _LessonMainState();
}

class _LessonMainState extends State<LessonMain> {
  late LessonStateManager controller;
  List<bool> selectedToggle = [true, false];
  String selectedLevel = '초급';
  late LessonSubject lessonSubject;
  late LessonTitle lessonTitle;
  late Map<String, TextEditingController> controllersSubject;
  late Map<String, TextEditingController> controllersTitle;
  late List<Map<String, dynamic>> controllersWritingTitle;

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
              reference: 'LessonSubjects',
              query: 'isBeginnerMode',
              equalTo: true,
              orderBy: 'orderId',
              descending: false)
          : controller.futureList = Database().getDocumentsFromDb(
              reference: 'LessonSubjects',
              query: 'isBeginnerMode',
              equalTo: false,
              orderBy: 'orderId',
              descending: false);
    } else {
      controller.futureList = Database().getDocumentsFromDb(reference: 'LessonTitles', orderBy: 'isFree');
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget getLevelRadioBtn(String value) {
      return MyRadioBtn().getRadioButton(
        context: context,
        value: value,
        groupValue: selectedLevel,
        f: (String? value) {
          setState(() {
            selectedLevel = value!;
            getDataFromDb();
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
                            getDataFromDb();
                          }
                        });
                      },
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      selectedBorderColor: Theme.of(context).colorScheme.primary,
                      selectedColor: Colors.white,
                      fillColor: Theme.of(context).colorScheme.primary,
                      color: Theme.of(context).colorScheme.primary,
                      isSelected: selectedToggle,
                      children: const [
                        Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('주제')),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('타이틀')),
                      ],
                    ),
                    const SizedBox(width: 20),
                    selectedToggle[0] ? getLevelRadioBtn('초급') : const SizedBox.shrink(),
                    selectedToggle[0] ? getLevelRadioBtn('중급') : const SizedBox.shrink(),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    openDialog(isNew: true);
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
              child: selectedToggle[0] ? LessonSubjectMain().subjectTable : LessonTitleMain().titleTable,
            ),
          ],
        ),
      ),
    );
  }

  initDialog() {
    controller.selectedLanguage = 'en';
    controller.isFreeLessonChecked = true;
    controllersSubject = {};
    controllersSubject = {
      'ko': TextEditingController(),
      'fo': TextEditingController(),
      'desc': TextEditingController()
    };
    controllersTitle = {};
    controllersTitle = {
      'ko': TextEditingController(),
      'fo': TextEditingController(),
      'gram': TextEditingController(),
    };
    controllersWritingTitle = [];
    controllersWritingTitle.add({'ko': TextEditingController(), 'fo': TextEditingController()});
    lessonSubject = LessonSubject();
    lessonTitle = LessonTitle();
  }

  openDialog({required bool isNew}) {
    initDialog();
    String title;
    Widget widget;

    //todo: isNew 가 false 일 때 controller setting 하기

    if (selectedToggle[0]) {
      selectedLevel == '초급' ? title = '레슨주제(초급)' : title = '레슨주제(중급)';
    } else {
      title = '레슨타이틀';
    }

    Get.dialog(AlertDialog(
      title: Text(title),
      content: GetBuilder<LessonStateManager>(
        builder: (_) {
          String selectedLanguage = controller.selectedLanguage;

          if (selectedToggle[0]) {
            controllersSubject['fo']!.text = lessonSubject.subject[selectedLanguage] ?? '';
            controllersSubject['desc']!.text = lessonSubject.description[selectedLanguage] ?? '';
            widget = getSubjectDialog(isNew: isNew);

          } else {
            controllersTitle['fo']!.text = lessonTitle.title[selectedLanguage] ?? '';
            for (int i = 0; i < controllersWritingTitle.length; i++) {
              controllersWritingTitle[i]['ko']!.text = lessonTitle.writingTitles[i].title['ko'] ?? '';
              controllersWritingTitle[i]['fo']!.text =
                  lessonTitle.writingTitles[i].title[selectedLanguage] ?? '';
            }
            widget = getTitleDialog(isNew: isNew);
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

  Widget getSubjectDialog({required isNew}) {
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
                    //todo: image upload
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
                  getTextField(
                    controller: controllersSubject['ko'],
                    label: '주제입력(한국어)',
                    fn: (String? value) {
                      lessonSubject.subject['ko'] = value!;
                    },
                  ),
                  const SizedBox(height: 20),
                  getTextField(
                    controller: controllersSubject['fo'],
                    label: '주제입력(외국어)',
                    fn: (String? value) {
                      lessonSubject.subject[controller.selectedLanguage] = value!;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 50),
        getTextField(
          controller: controllersSubject['desc'],
          label: '설명',
          fn: (String? value) {
            lessonSubject.description[controller.selectedLanguage] = value!;
          },
          minLine: 5,
        ),
        const SizedBox(height: 50),
        ElevatedButton(
          onPressed: () {
            setState(() {
              int index = controller.lessonSubjects.length;
              lessonSubject.orderId = index;
              selectedLevel == '초급'
                  ? lessonSubject.isBeginnerMode = true
                  : lessonSubject.isBeginnerMode = false;
              Database().saveLessonToDb(reference: 'LessonSubjects', lesson: lessonSubject);
              getDataFromDb();
              Get.back();
            });
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text('저장', style: TextStyle(fontSize: 20)),
          ),
        ),
      ],
    );
  }

  Widget getTitleDialog({required isNew}) {
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
                  child: getTextField(
                      controller: controllersTitle['ko'],
                      label: '한국어',
                      fn: (String? value) {
                        lessonTitle.title['ko'] = value!;
                      })),
              const SizedBox(width: 20),
              Expanded(
                  child: getTextField(
                      controller: controllersTitle['fo'],
                      label: '외국어',
                      fn: (String? value) {
                        lessonTitle.title[controller.selectedLanguage] = value!;
                      })),
              const SizedBox(width: 20),
              Expanded(
                  child: getTextField(
                      controller: controllersTitle['gram'],
                      label: '문법',
                      fn: (String? value) {
                        lessonTitle.titleGrammar = value!;
                      })),
              const SizedBox(width: 20),
              Column(
                children: [
                  const Text('무료'),
                  Checkbox(
                      value: controller.isFreeLessonChecked,
                      onChanged: (value) {
                        controller.isFreeLessonChecked = value!;
                        lessonTitle.isFree = value!;
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
                    lessonTitle.writingTitles.add(WritingTitle());
                    controllersWritingTitle.add({'ko': TextEditingController(), 'fo': TextEditingController()});
                    controller.update();
                  },
                  icon: Icon(Icons.add_circle_outline_rounded,
                      size: 30, color: Theme.of(context).colorScheme.primary)),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: controllersWritingTitle.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                          child: getTextField(
                              controller: controllersWritingTitle[index]['ko'],
                              label: '한국어',
                              fn: (String? value) {
                                lessonTitle.writingTitles[index].title['ko'] = value!;
                              })),
                      const SizedBox(width: 20),
                      Expanded(
                          child: getTextField(
                              controller: controllersWritingTitle[index]['fo'],
                              label: '외국어',
                              fn: (String? value) {
                                lessonTitle.writingTitles[index].title[controller.selectedLanguage] =
                                    value!;
                              })),
                      const SizedBox(width: 20),
                      DropdownButton(
                          value: lessonTitle.writingTitles[index].level,
                          icon: const Icon(Icons.arrow_drop_down_outlined),
                          items: controller.levelDropdownList.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem(value: value, child: Text(value));
                          }).toList(),
                          onChanged: (String? value) {
                            lessonTitle.writingTitles[index].level = value!;
                            controller.update();
                          }),
                      const SizedBox(width: 20),
                      Column(
                        children: [
                          const Text('무료'),
                          Checkbox(
                              value: lessonTitle.writingTitles[index].isFree,
                              onChanged: (value) {
                                lessonTitle.writingTitles[index].isFree = value!;
                                controller.update();
                              }),
                        ],
                      ),
                      const SizedBox(width: 30),
                      IconButton(
                          onPressed: () {
                            lessonTitle.writingTitles.removeAt(index);
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
            ),
          ),
          const SizedBox(height: 50),
          Center(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  Database().saveLessonToDb(reference: 'LessonTitles', lesson: lessonTitle);
                  getDataFromDb();
                  Get.back();
                });
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

  Widget getTextField(
      {required controller,
      required String label,
      required Function(String?) fn,
      int minLine = 1,
      bool enable = true}) {
    return TextField(
      enabled: enable,
      minLines: minLine,
      controller: controller,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      decoration: InputDecoration(
        labelText: label,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 1, color: Theme.of(context).colorScheme.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 1, color: Theme.of(context).colorScheme.primary),
        ),
      ),
      onChanged: fn,
    );
  }
}
