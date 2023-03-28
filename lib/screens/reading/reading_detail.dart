import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/languages.dart';
import 'package:podo_admin/common/my_textfield.dart';
import 'package:podo_admin/screens/reading/reading.dart';
import 'package:podo_admin/screens/reading/reading_state_manager.dart';

class ReadingDetail extends StatefulWidget {
  const ReadingDetail({Key? key}) : super(key: key);

  @override
  State<ReadingDetail> createState() => _ReadingDetailState();
}

class _ReadingDetailState extends State<ReadingDetail> {
  //final controller = Get.find<ReadingStateManager>();
  final controller = Get.put(ReadingStateManager());
  final ScrollController scrollController = ScrollController();
  final double cardWidth = 350;
  late Map<String, TextEditingController> controllers;
  late Reading reading;
  final textEditControllerForKo = TextEditingController();

  @override
  void initState() {
    super.initState();
    reading = Get.arguments ?? Reading();
  }

  Widget getCards() {
    List<Widget> cards = [];
    cards.add(readingCard(language: 'ko'));
    for (String lang in Languages().languages) {
      cards.add(readingCard(language: lang));
    }
    return Row(children: cards);
  }

  Widget textFieldForKoTitle({String content = ''}) {
    return TextField(
      controller: textEditControllerForKo,
      selectionControls: MaterialTextSelectionControls(),
      onTap: () {
        textEditControllerForKo.selection =
            TextSelection.collapsed(offset: textEditControllerForKo.text.length);
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: '제목',
      ),
      onChanged: (value) {
        reading.title['ko'] = value;
      },
    );
  }

  Widget readingCard({required String language}) {
    Widget widget = Column(
      children: [
        Row(
          children: [
            Text(language),
            const SizedBox(width: 20),
            language == 'ko'
                ? ElevatedButton(
                onPressed: () {
                  String selectedText = '';
                  int start = textEditControllerForKo.selection.start;
                  int end = textEditControllerForKo.selection.end;
                  if (start != end) {
                    String wholeText = textEditControllerForKo.text;
                    selectedText = textEditControllerForKo.text.substring(start, end);
                    wholeText = wholeText.replaceRange(start, end, '&&$selectedText&&');
                    textEditControllerForKo.text = wholeText;
                  }
                },
                child: const Text('단어설정'))
                : const SizedBox.shrink(),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: cardWidth,
                  child: SingleChildScrollView(
                      child: Column(
                        children: [
                          language == 'ko'
                              ? textFieldForKoTitle()
                              : MyTextField().getTextField(
                              controller: TextEditingController(),
                              label: '제목',
                              fn: (value) {
                                reading.title[language] = value;
                              }),
                          const SizedBox(height: 10),
                          MyTextField().getTextField(
                              controller: TextEditingController(),
                              label: '내용',
                              minLine: 10,
                              fn: (value) {
                                reading.content[language] = value;
                              }),
                        ],
                      )),
                ),
              ),
            ),
          ),
        ),
      ],
    );
    return widget;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('읽기_상세'),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              DropdownButton(
                value: controller.readingLevel[reading.level],
                icon: const Icon(Icons.arrow_drop_down_outlined),
                items: controller.readingLevel.map<DropdownMenuItem<String>>((value) {
                  return DropdownMenuItem(value: value, child: Text(value));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    reading.level = controller.readingLevel.indexOf(value.toString());
                  });
                },
              ),
              const SizedBox(width: 20),
              ElevatedButton(onPressed: () {}, child: const Text('단어입력')),
              const SizedBox(width: 20),
              ElevatedButton(onPressed: () {}, child: const Text('퀴즈입력')),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Scrollbar(
            controller: scrollController,
            child: SingleChildScrollView(
                controller: scrollController, scrollDirection: Axis.horizontal, child: getCards()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(30),
          child: ElevatedButton(
            onPressed: () async {
              print(reading.content);
              // for (LessonSummaryItem item in _controller.lessonSummary.contents) {
              //   print('kr : ${item.subjectKr}');
              //   print('en : ${item.subjectEn}');
              //   print('explain : ${item.explain}');
              //   for (String example in item.examples) {
              //     print(example);
              //   }
              // }
              // final firestore = FirebaseFirestore.instance;
              // LessonCard card = _controller.cardItems[0];
              // firestore.collection('lessonCard').doc(card.lessonId).set(card.toJson());

              // for (LessonCard card in _controller.cardItems) {
              //   Database().saveLessonCard(card);
              // }
              //
              // for (LessonSummary summary in _controller.lessonSummaries) {
              //   Database().saveLessonSummary(summary);
              // }
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                '저장',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
