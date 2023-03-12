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
  LessonStateManager controller = Get.put(LessonStateManager());
  List<bool> selectedToggle = [true, false];
  String selectedLevel = '초급';
  List<LessonSubject> lessonSubjects = [];
  List<LessonTitle> lessonTitles = [];
  late Future<List<dynamic>> future;
  late LessonSubject newSubject;
  late LessonTitle newTitle;

  @override
  Widget build(BuildContext context) {
    if (selectedToggle[0] && lessonSubjects.isEmpty) {
      selectedLevel == '초급'
          ? future = Database().getDocumentsFromDb(
              reference: 'LessonSubjects',
              query: 'isBeginnerMode',
              equalTo: true,
              orderBy: 'orderId',
              descending: false)
          : future = Database().getDocumentsFromDb(
              reference: 'LessonSubjects',
              query: 'isBeginnerMode',
              equalTo: false,
              orderBy: 'orderId',
              descending: false);
    }

    if (selectedToggle[1] && lessonTitles.isEmpty) {
      future = Database().getDocumentsFromDb(reference: 'LessonTitles', orderBy: 'isFree');
    }

    Widget getLevelRadioBtn(String value) {
      return MyRadioBtn().getRadioButton(
        context: context,
        value: value,
        groupValue: selectedLevel,
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
              child: selectedToggle[0]
                  ? LessonSubjectMain(future, selectedLevel == '초급' ? true : false).subjectTable
                  : LessonTitleMain(future).titleTable,
            ),
          ],
        ),
      ),
    );
  }

  openDialog({required bool isNew}) {
    newSubject = LessonSubject();
    newTitle = LessonTitle();
    String title;
    Widget widget;
    // 레슨 주제
    if (selectedToggle[0]) {
      selectedLevel == '초급' ? title = '레슨주제_만들기(초급)' : title = '레슨주제_만들기(중급)';
      isNew ? null : title = '레슨주제';
      widget = getSubjectDialog(isNew: isNew);

      // 레슨 타이틀
    } else {
      isNew ? title = '레슨타이틀_만들기' : title = '레슨타이틀';
      widget = getTitleDialog(isNew: isNew);
    }

    Get.dialog(AlertDialog(
      title: Text(title),
      content: GetX<LessonStateManager>(
        builder: (controller) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('언어선택', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    getLanguageRadio(controller.languageMap['en']!),
                    getLanguageRadio(controller.languageMap['es']!),
                    getLanguageRadio(controller.languageMap['fr']!),
                    getLanguageRadio(controller.languageMap['de']!),
                    getLanguageRadio(controller.languageMap['pt']!, width: 160),
                    getLanguageRadio(controller.languageMap['id']!, width: 175),
                    getLanguageRadio(controller.languageMap['ru']!),
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
                    label: '주제입력(한국어)',
                    fn: (String? value) {
                      newSubject.subject_ko = value!;
                    },
                  ),
                  const SizedBox(height: 20),
                  getTextField(
                    label: '주제입력(외국어)',
                    fn: (String? value) {
                      newSubject.subject_foreign[getLanguageMapKey()] = value!;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 50),
        getTextField(
          label: '설명',
          fn: (String? value) {
            newSubject.content_foreign[getLanguageMapKey()] = value!;
          },
          minLine: 5,
          enable: selectedLevel == '초급' ? true : false,
        ),
        const SizedBox(height: 50),
        ElevatedButton(
          onPressed: () {
            //todo: save
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text('저장', style: TextStyle(fontSize: 20)),
          ),
        ),
      ],
    );
  }

  String getLanguageMapKey() {
    return controller.languageMap.keys
        .firstWhere((key) => controller.languageMap[key] == controller.selectedLanguage.value);
  }

  Widget getTitleDialog({required isNew}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('레슨타이틀', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: getTextField(label: '한국어', fn: (String? value) {})),
            const SizedBox(width: 20),
            Expanded(child: getTextField(label: '외국어', fn: (String? value) {})),
            const SizedBox(width: 20),
            Expanded(child: getTextField(label: '문법', fn: (String? value) {})),
            const SizedBox(width: 20),
            Column(
              children: [
                const Text('무료'),
                Checkbox(
                    value: controller.isChecked.value,
                    onChanged: (value) {
                      controller.isChecked.value = value!;
                    }),
              ],
            )
          ],
        ),
        const SizedBox(height: 30),
        const Text('쓰기타이틀', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: getTextField(label: '한국어', fn: (String? value) {})),
            const SizedBox(width: 20),
            Expanded(child: getTextField(label: '외국어', fn: (String? value) {})),
            const SizedBox(width: 20),
            DropdownButton(
                value: controller.levelDropdownList.first,
                icon: const Icon(Icons.arrow_drop_down_outlined),
                items: controller.levelDropdownList.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem(value: value, child: Text(value));
                }).toList(),
                onChanged: (String? value) {}),
            const SizedBox(width: 20),
            Column(
              children: [
                const Text('무료'),
                Checkbox(
                    value: controller.isChecked.value,
                    onChanged: (value) {
                      controller.isChecked.value = value!;
                    }),
              ],
            ),
            const SizedBox(width: 30),
            IconButton(
                onPressed: () {
                  //todo: remove writing title
                },
                icon: const Icon(
                  Icons.remove_circle_outline_rounded,
                  size: 30,
                  color: Colors.red,
                )),
          ],
        ),
        const SizedBox(height: 20),
        IconButton(
            onPressed: () {
              //todo: add writing title
            },
            icon: Icon(Icons.add_circle_outline_rounded,
                size: 30, color: Theme.of(context).colorScheme.primary)),
        const SizedBox(height: 50),
        Center(
          child: ElevatedButton(
            onPressed: () {
              //todo: save
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text('저장', style: TextStyle(fontSize: 20)),
            ),
          ),
        ),
      ],
    );
  }

  Widget getLanguageRadio(String lang, {double width = 150}) {
    return MyRadioBtn().getRadioButton(
        context: context,
        value: lang,
        width: width,
        groupValue: controller.selectedLanguage.value,
        f: (String? value) {
          controller.selectedLanguage.value = value!;
        });
  }

  Widget getTextField(
      {required String label, required Function(String?) fn, int minLine = 1, bool enable = true}) {
    return TextField(
      enabled: enable,
      minLines: minLine,
      controller: TextEditingController(),
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
