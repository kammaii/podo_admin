import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/common/languages.dart';
import 'package:podo_admin/common/my_textfield.dart';
import 'package:podo_admin/screens/reading/reading.dart';
import 'package:podo_admin/screens/reading/reading_state_manager.dart';
import 'package:translator/translator.dart';

class ReadingDetail extends StatefulWidget {
  const ReadingDetail({Key? key}) : super(key: key);

  @override
  State<ReadingDetail> createState() => _ReadingDetailState();
}

class _ReadingDetailState extends State<ReadingDetail> {
  final controller = Get.find<ReadingStateManager>();
  final sc1 = ScrollController();
  final sc2 = ScrollController();
  final sc3 = ScrollController();
  final double cardWidth = 350;
  late Map<String, TextEditingController> controllers;
  late Reading reading;
  final textEditControllerForKo = TextEditingController();
  final translator = GoogleTranslator();
  final languages = [...Languages().getFos];
  Map<String, List<String>> wordsMap = {};
  late Map<int, dynamic> quizMap;

  @override
  void initState() {
    super.initState();
    reading = Get.arguments ?? Reading();
    languages.insert(0, 'ko');
    quizMap = {...reading.quizzes};
  }

  Widget getCards() {
    List<Widget> cards = [];
    cards.add(readingCard(language: 'ko'));
    for (String lang in Languages().getFos) {
      cards.add(readingCard(language: lang));
    }
    return Row(children: cards);
  }

  Widget textFieldForKoContent() {
    return TextField(
      maxLines: null,
      minLines: 10,
      controller: textEditControllerForKo,
      selectionControls: MaterialTextSelectionControls(),
      onTap: () {
        textEditControllerForKo.selection =
            TextSelection.collapsed(offset: textEditControllerForKo.text.length);
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: '내용',
      ),
      onChanged: (value) {
        reading.content['ko'] = value;
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
                      MyTextField().getTextField(
                          controller: TextEditingController(text: reading.title[language]),
                          label: '제목',
                          fn: (value) {
                            reading.title[language] = value;
                          }),
                      const SizedBox(height: 10),
                      language == 'ko'
                          ? textFieldForKoContent()
                          : MyTextField().getTextField(
                              controller: TextEditingController(text: reading.content[language]),
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
        title: Text('읽기_상세 (${reading.id})'),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: GetBuilder<ReadingStateManager>(
            builder: (controller) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  DropdownButton(
                    value: reading.category,
                    icon: const Icon(Icons.arrow_drop_down_outlined),
                    items: controller.categories.map<DropdownMenuItem<String>>((value) {
                      return DropdownMenuItem(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (value) {
                      reading.category = value.toString();
                      controller.update();
                    },
                  ),
                  const SizedBox(width: 20),
                  DropdownButton(
                    value: controller.readingLevel[reading.level],
                    icon: const Icon(Icons.arrow_drop_down_outlined),
                    items: controller.readingLevel.map<DropdownMenuItem<String>>((value) {
                      return DropdownMenuItem(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (value) {
                      reading.level = controller.readingLevel.indexOf(value.toString());
                      controller.update();
                    },
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                      onPressed: () {
                        String? contentKo = reading.content['ko'];
                        if(contentKo != null && contentKo.contains('&&')) {
                          Get.dialog(AlertDialog(
                            title: const Text('자동번역을 사용하겠습니까?'),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Get.back();
                                    final future = getTranslatedFuture();
                                    Get.dialog(AlertDialog(
                                      title: const Text('단어입력'),
                                      content: FutureBuilder(
                                        future: future,
                                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                                          if (snapshot.hasData &&
                                              snapshot.connectionState != ConnectionState.waiting) {
                                            return Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Scrollbar(
                                                  controller: sc2,
                                                  child: SingleChildScrollView(
                                                    controller: sc2,
                                                    scrollDirection: Axis.horizontal,
                                                    child: Column(
                                                      children: List.generate(
                                                        Languages().getFos.length + 1,
                                                            (index) =>
                                                            getWordList(
                                                                index, snapshot.data[languages[index]]),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                                ElevatedButton(
                                                    onPressed: () {
                                                      saveWords();
                                                    },
                                                    child: const Text('저장', style: TextStyle(fontSize: 20))),
                                              ],
                                            );
                                          } else {
                                            return const Center(child: CircularProgressIndicator());
                                          }
                                        },
                                      ),
                                    ));
                                  },
                                  child: const Text('네')),
                              TextButton(
                                  onPressed: () {
                                    Get.back();
                                    Get.dialog(AlertDialog(
                                      title: const Text('단어입력'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Scrollbar(
                                            controller: sc2,
                                            child: SingleChildScrollView(
                                              controller: sc2,
                                              scrollDirection: Axis.horizontal,
                                              child: Column(
                                                children: List.generate(
                                                  Languages().getFos.length + 1,
                                                      (index) => getWordList(index, reading.words[languages[index]]),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          ElevatedButton(
                                              onPressed: () {
                                                saveWords();
                                              },
                                              child: const Text('저장', style: TextStyle(fontSize: 20))),
                                        ],
                                      ),
                                    ));
                                  },
                                  child: const Text('아니오')),
                            ],
                          ));
                        } else {
                          Get.dialog(const AlertDialog(title: Text('단어가 없습니다.')));
                        }
                      },
                      child: const Text('단어입력')),
                  const SizedBox(width: 20),
                  ElevatedButton(
                      onPressed: () {
                        Get.dialog(AlertDialog(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('퀴즈입력'),
                              Row(
                                children: [
                                  TextButton(
                                      onPressed: () {
                                        if (quizMap.isNotEmpty) {
                                          int maxKey = quizMap.keys.reduce((a, b) => a > b ? a : b);
                                          quizMap.remove(maxKey);
                                          controller.update();
                                        }
                                      },
                                      child: const Text('삭제', style: TextStyle(color: Colors.red))),
                                  const SizedBox(width: 10),
                                  TextButton(
                                      onPressed: () {
                                        int nextKey = quizMap.keys.isNotEmpty
                                            ? quizMap.keys.reduce((a, b) => a > b ? a : b) + 1
                                            : 0;
                                        quizMap[nextKey] = List.generate(5, (index) => '');
                                        controller.update();
                                      },
                                      child: const Text('추가')),
                                ],
                              ),
                            ],
                          ),
                          content: GetBuilder<ReadingStateManager>(
                            builder: (controller) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Scrollbar(
                                    controller: sc3,
                                    child: SingleChildScrollView(
                                      controller: sc3,
                                      scrollDirection: Axis.horizontal,
                                      child: Column(
                                        children: List.generate(5, (index) => getQuizList(index)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                      onPressed: () {
                                        reading.quizzes = {...quizMap};
                                        Get.back();
                                      },
                                      child: const Text('저장', style: TextStyle(fontSize: 20))),
                                ],
                              );
                            },
                          ),
                        ));
                      },
                      child: const Text('퀴즈입력')),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Scrollbar(
            controller: sc1,
            child:
                SingleChildScrollView(controller: sc1, scrollDirection: Axis.horizontal, child: getCards()),
          ),
        ),
        const SizedBox(height: 10),
        const Text('# 주의 : 읽기 내용이 확정된 후에 단어를 입력할 것!', style: TextStyle(color: Colors.red)),
        Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: () {
              Database().setDoc(collection: 'Readings', doc: reading);
              Get.back();
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

  Future<dynamic> getTranslatedFuture() async {
    final wholeText = textEditControllerForKo.text;
    final regex = RegExp(r'&&(.+?)&&');
    final matches = regex.allMatches(wholeText);
    final wordsFuture = {};

    if (matches.isNotEmpty) {
      for (int i = 0; i < languages.length; i++) {
        wordsMap[languages[i]] = List.generate(matches.length, (index) => '');
        wordsFuture[languages[i]] = [];
        for (final match in matches) {
          final word = await translator.translate(match.group(1)!, to: languages[i]);
          wordsFuture[languages[i]].add(word);
        }
      }
      return wordsFuture;
    } else {
      return;
    }
  }

  Widget getWordList(int index, dynamic snapshot) {
    List<Widget> widgets = [];
    widgets.add(SizedBox(width: 50, child: Text(languages[index])));
    List<String> words = [];
    wordsMap[languages[index]] = words;
    for (int i = 0; i < snapshot.length; i++) {
      String word = snapshot[i].toString();
      words.add(word);
      widgets.add(SizedBox(
        width: 150,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: MyTextField().getTextField(
              controller: TextEditingController(text: word),
              fn: (value) {
                words[i] = value;
              }),
        ),
      ));
    }
    return Row(
      children: widgets,
    );
  }

  void saveWords() {
    for (final lang in languages) {
      reading.words[lang] = [...?wordsMap[lang]];
    }
    Get.back();
  }

  Widget getQuizList(int index) {
    List<Widget> widgets = [];
    final titles = ['질문', '보기1(정답)', '보기2', '보기3', '보기4'];
    widgets.add(SizedBox(width: 100, child: Text(titles[index])));

    for (int i = 0; i < quizMap.length; i++) {
      final quiz = quizMap[i];
      widgets.add(SizedBox(
        width: 200,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: MyTextField().getTextField(
              controller: TextEditingController(text: quiz![index]),
              fn: (value) {
                quiz[index] = value;
              }),
        ),
      ));
    }
    return Row(
      children: widgets,
    );
  }
}
