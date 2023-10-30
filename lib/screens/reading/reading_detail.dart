import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/common/deepl_translator.dart';
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
  final translator = GoogleTranslator();
  final languages = [...Languages().getFos];
  List<Reading> readings = [];
  String translatingId = '';


  @override
  void initState() {
    super.initState();
    readingTitle = Get.arguments;
    languages.insert(0, 'ko');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadReadings(readingTitle.id);
    });
  }

  void runTranslation(String id, Map<String, dynamic> map, {bool isSetState = true}) {
    translatingId = id;
    if (isSetState) {
      setState(() {
        controller.isTranslating = true;
      });
      DeeplTranslator().getTranslations(map).then((value) => setState(() {
        controller.isTranslating = false;
      }));
    } else {
      controller.changeTransState(true);
      DeeplTranslator().getTranslations(map).then((value) {
        controller.changeTransState(false);
      }).catchError((e) {
        Get.snackbar('번역 오류 발생', e.toString(), snackPosition: SnackPosition.BOTTOM);
        controller.changeTransState(false);
      });
    }
  }

  Widget getTransBtn(String id) {
    return Row(
      children: [
        const Text('번역'),
        const SizedBox(width: 10),
        controller.isTranslating && id == translatingId
            ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 1.5))
            : const SizedBox.shrink()
      ],
    );
  }

  void loadReadings(String readingTitleId) async {
    readings = [];
    final snapshots = await Database()
        .getDocs(collection: 'ReadingTitles/$readingTitleId/Readings', orderBy: 'orderId', descending: false);
    if (snapshots.isNotEmpty) {
      setState(() {
        for (dynamic snapshot in snapshots) {
          readings.add(Reading.fromJson(snapshot));
        }
      });
    } else {
      int length = 0;
      Get.dialog(AlertDialog(
        title: const Text('읽기 카드 개수를 입력하세요.'),
        content: MyTextField().getTextField(fn: (value) {
          length = int.parse(value);
        }),
        actions: [
          TextButton(
              onPressed: () {
                setState(() {
                  Get.back();
                  readings = List.generate(length, (index) => Reading(index));
                });
              },
              child: const Text('카드 만들기'))
        ],
      ));
    }
  }

  Widget wordsDialog(Reading reading) {
    return AlertDialog(
      title: Row(
        children: [
          const Text('단어입력'),
          const SizedBox(width: 20),
          TextButton(onPressed: (){
            DeeplTranslator().getWordTranslations(controller, reading.words).then((value) => controller.update());
          }, child: Row(
            children: [
              const Text('번역'),
              const SizedBox(width: 10),
              controller.isTranslating
                  ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 1.5))
                  : const SizedBox.shrink()
            ],
          ),),
        ],
      ),
      content: getWordList(reading),
    );
  }

  Widget getCards() {
    List<Widget> cards = [];
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

    Widget widget = Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Row(
            children: [
              Text(index.toString()),
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
                  icon: const Icon(Icons.delete_rounded, color: Colors.red)),
              const SizedBox(width: 10),
              TextButton(
                  onPressed: () {
                    runTranslation(reading.id, reading.content);
                  },
                  child: getTransBtn(reading.id)),
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
                                    title: const Text('새로 입력을 하시겠습니까?'),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Get.back();
                                            int wordsLength = reading.words['ko'].length;
                                            for (int i = 1; i < languages.length; i++) {
                                              reading.words[languages[i]] = List.filled(wordsLength, '');
                                            }
                                            Get.dialog(wordsDialog(reading));
                                          },
                                          child: const Text('네')),
                                      TextButton(
                                          onPressed: () {
                                            Get.back();
                                            Get.dialog(wordsDialog(reading));
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
          const SizedBox(height: 10),
          GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: reading.id));
                Get.snackbar('아이디가 클립보드에 저장되었습니다.', reading.id, snackPosition: SnackPosition.BOTTOM);
              },
              child: Text(reading.id)),
        ],
      ),
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

  Widget getWordList(Reading reading) {
    return GetBuilder<ReadingStateManager>(
      builder: (_) {
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
                    print('$language: $words');
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
      },
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
