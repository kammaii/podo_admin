import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/common/languages.dart';
import 'package:podo_admin/common/my_textfield.dart';
import 'package:podo_admin/screens/reading/reading.dart';
import 'package:podo_admin/screens/reading/reading_title.dart';
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
  final double cardWidth = 400;
  late ReadingTitle readingTitle;
  List<Reading> readings = [];
  final translator = GoogleTranslator();
  final languages = [...Languages().getFos];

  @override
  void initState() {
    super.initState();
    readingTitle = Get.arguments;
    languages.insert(0, 'ko');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadReadings(readingTitle.id);
    });
  }

  void loadReadings(String readingTitleId) async {
    readings = [];
    final snapshots =
        await Database().getDocs(collection: 'ReadingTitles/$readingTitleId/Readings', orderBy: 'orderId', descending: false);
    setState(() {
      if (snapshots.isNotEmpty) {
        for (dynamic snapshot in snapshots) {
          readings.add(Reading.fromJson(snapshot));
        }
      }
    });
  }

  Widget getCards() {
    List<Widget> cards = [];
    if (readings.isEmpty) {
      readings.add(Reading(0));
    }
    for (int i = 0; i < readings.length; i++) {
      cards.add(readingCard(i));
    }
    return Row(children: cards);
  }

  Widget readingCard(int index) {
    Reading reading = readings[index];
    String words = '';
    if (reading.words['ko'] != null) {
      for (String word in reading.words['ko']) {
        words = '$words$word,';
      }
    }
    final wordsController = TextEditingController(text: words);

    Widget widget = Column(
      children: [
        Row(
          children: [
            Text(reading.id),
            const SizedBox(width: 20),
            IconButton(
                onPressed: () {
                  setState(() {
                    for (int i = 0; i < readings.length; i++) {
                      if (readings[i].id == reading.id) {
                        readings.removeAt(i);
                        break;
                      }
                    }
                  });
                },
                icon: const Icon(Icons.delete_rounded, color: Colors.red))
          ],
        ),
        const SizedBox(height: 10),
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
                        getTextField(index, 'ko'),
                        getTextField(index, Languages().getFos[0]),
                        getTextField(index, Languages().getFos[1]),
                        getTextField(index, Languages().getFos[2]),
                        getTextField(index, Languages().getFos[3]),
                        getTextField(index, Languages().getFos[4]),
                        getTextField(index, Languages().getFos[5]),
                        getTextField(index, Languages().getFos[6]),
                        SizedBox(
                          width: cardWidth,
                          child: Row(
                            children: [
                              const SizedBox(width: 50, child: Text('단어')),
                              Expanded(
                                child: MyTextField().getTextField(
                                    controller: wordsController,
                                    label: '단어리스트',
                                    minLine: 2,
                                    fn: (value) {
                                      if (value.endsWith(',')) {
                                        value.substring(0, value.length - 1);
                                      }
                                      reading.words['ko'] = value.split(',');
                                    }),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                            onPressed: () {
                              if (reading.words['ko'] != null && reading.words['ko'].isNotEmpty) {
                                Get.dialog(AlertDialog(
                                  title: const Text('자동번역을 사용하겠습니까?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Get.back();
                                          Get.dialog(
                                            AlertDialog(
                                                title: const Text('단어입력'),
                                                content: FutureBuilder(
                                                  future: getTranslatedWord(reading),
                                                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                                                    if (snapshot.connectionState != ConnectionState.waiting) {
                                                      return getWordList(reading);
                                                    } else {
                                                      return const Center(child: CircularProgressIndicator());
                                                    }
                                                  },
                                                )),
                                          );
                                        },
                                        child: const Text('네')),
                                    TextButton(
                                        onPressed: () {
                                          Get.back();
                                          Get.dialog(AlertDialog(
                                            title: const Text('단어입력'),
                                            content: getWordList(reading),
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
    return widget;
  }

  Widget getTextField(int index, String lang) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(width: 50, child: Text(lang)),
          Expanded(
            child: MyTextField().getTextField(
                controller: TextEditingController(text: readings[index].content[lang]),
                label: lang,
                fn: (value) {
                  readings[index].content[lang] = value;
                }),
          ),
        ],
      ),
    );
  }

  Future<void> getTranslatedWord(Reading reading) async {
    List<String> wordList = reading.words['ko'];
    for (int i = 1; i < languages.length; i++) {
      String language = languages[i];
      reading.words[language] = [];

      for (String word in wordList) {
        final translatedWord = await translator.translate(word, to: language);
        reading.words[language].add(translatedWord.toString());
      }
    }
    return;
  }

  Widget getWordList(Reading reading) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Scrollbar(
          controller: sc2,
          child: SingleChildScrollView(
            controller: sc2,
            scrollDirection: Axis.horizontal,
            child: Column(
              children: List.generate(languages.length, (index) {
                String language = languages[index];
                List<dynamic> words = reading.words[language];
                List<Widget> widgets = [];
                widgets.add(SizedBox(width: 50, child: Text(language)));
                for (int i = 0; i < words.length; i++) {
                  widgets.add(SizedBox(
                    width: 150,
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: MyTextField().getTextField(
                          controller: TextEditingController(text: words[i]),
                          fn: (value) {
                            reading.words[language][i] = value;
                          }),
                    ),
                  ));
                }

                return Row(
                  children: widgets,
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('닫기', style: TextStyle(fontSize: 20))),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${readingTitle.title['ko']} (${readingTitle.id})'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Scrollbar(
                controller: sc1,
                child: SingleChildScrollView(
                    controller: sc1,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        getCards(),
                        Center(
                          child: IconButton(
                            icon: const Icon(Icons.add_circle_outline_rounded),
                            color: Colors.purple,
                            onPressed: () {
                              setState(() {
                                readings.add(Reading(readings.length));
                              });
                            },
                          ),
                        )
                      ],
                    )),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: () async {
                      Get.back();
                      for (Reading reading in readings) {
                        await Database()
                            .setDoc(collection: 'ReadingTitles/${readingTitle.id}/Readings', doc: reading);
                      }
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
