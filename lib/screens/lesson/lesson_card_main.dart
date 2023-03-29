import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/common/languages.dart';
import 'package:podo_admin/common/my_html_color.dart';
import 'package:podo_admin/common/my_radio_btn.dart';
import 'package:podo_admin/screens/lesson/inner_card_textfield.dart';
import 'package:podo_admin/screens/lesson/lesson_card.dart';
import 'package:podo_admin/screens/lesson/lesson_state_manager.dart';
import 'package:podo_admin/screens/lesson/lesson_summary.dart';
import 'package:podo_admin/screens/value/my_strings.dart';

class LessonCardMain extends StatefulWidget {
  const LessonCardMain({Key? key}) : super(key: key);

  @override
  State<LessonCardMain> createState() => _LessonCardMainState();
}

class _LessonCardMainState extends State<LessonCardMain> {
  //final LessonTitle lessonTitle = Get.arguments;
  final sampleTitleId = '6cd5ea6c-faa4-4c49-866b-acacbd81116f';
  final sampleTitle = '학교에 가요';
  final _controller = Get.put(LessonStateManager());
  List<Widget> cardWidgets = [];
  final ScrollController scrollController = ScrollController();
  final double cardWidth = 350;
  late Map<String, TextEditingController> controllers;
  int explainFoIndex = 0;
  HtmlEditorController htmlEditorController = HtmlEditorController();

  @override
  void initState() {
    super.initState();
    _controller.cards = [];
    _controller.lessonSummaries = [];
    getCards();
  }

  getCards() async {
    _controller.cards = await Database()
        .getDocumentsFromDb(collection: 'LessonTitles/$sampleTitleId/LessonCards', orderBy: 'orderId');
    setState(() {});
  }

  void setCards() {
    cardWidgets = [];
    cardWidgets = List<Widget>.generate(
      _controller.cards.length,
      (index) {
        LessonCard card = _controller.cards[index];
        Widget? innerWidget;
        switch (card.type) {
          case MyStrings.subject:
            innerWidget = Column(
              children: [
                InnerCardTextField().getKo(index, 'ko'),
                const Divider(height: 30),
                InnerCardTextField().getFos(index),
              ],
            );
            break;

          case MyStrings.explain:
            if (explainFoIndex >= Languages().getFos.length) {
              explainFoIndex = 0;
            } else if (explainFoIndex < 0) {
              explainFoIndex = Languages().getFos.length - 1;
            }
            String language = Languages().getFos[explainFoIndex];
            print('$language: ${card.content[language]}');
            if (card.content[language] == null) {
              card.content[language] = '';
            }
            String explain = card.content[language];
            print('code1: ${explain.hashCode}');
            print('code2: ${card.content[language].hashCode}');
            print('$language: ${card.content[language]}');
            htmlEditorController.setText(language);
            print('$language: ${card.content[language]}');

            if ((_controller.isEditMode.containsKey(card.id) && _controller.isEditMode[card.id]!)) {
              innerWidget = Row(
                children: [
                  IconButton(
                      onPressed: () {
                        setState(() {
                          explainFoIndex--;
                        });
                      },
                      icon: const Icon(Icons.arrow_back_ios_rounded),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints()),
                  Expanded(
                    child: HtmlEditor(
                      controller: htmlEditorController,
                      htmlEditorOptions: HtmlEditorOptions(hint: MyStrings.explain, initialText: explain),
                      htmlToolbarOptions: HtmlToolbarOptions(
                        toolbarType: ToolbarType.nativeGrid,
                        defaultToolbarButtons: [
                          const StyleButtons(),
                          const ListButtons(listStyles: false),
                          const InsertButtons(),
                          const OtherButtons(
                              fullscreen: false,
                              undo: false,
                              redo: false,
                              copy: false,
                              paste: false,
                              help: false),
                        ],
                        customToolbarButtons: [
                          MyHtmlColor().colorButton(controller: htmlEditorController, color: MyStrings.red),
                          MyHtmlColor().colorButton(controller: htmlEditorController, color: MyStrings.blue),
                          MyHtmlColor().colorButton(controller: htmlEditorController, color: MyStrings.black),
                        ],
                      ),
                      callbacks: Callbacks(onChangeContent: (String? content) {
                        card.content[language] = content!;
                      }),
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          explainFoIndex++;
                        });
                      },
                      icon: const Icon(Icons.arrow_forward_ios_rounded),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints()),
                ],
              );
            } else {
              innerWidget = Text(explain);
            }
            break;

          case MyStrings.repeat:
            innerWidget = Column(
              children: [
                InnerCardTextField().getKo(index, 'ko'),
                const SizedBox(height: 5),
                InnerCardTextField().getKo(index, 'pronun'),
                const Divider(height: 30),
                InnerCardTextField().getFos(index),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _controller.cardType = MyStrings.speaking;
                      _controller.addCardItem();
                    });
                  },
                  child: const Text('말하기카드만들기'),
                )
              ],
            );
            break;

          case MyStrings.speaking:
            innerWidget = Column(
              children: [
                InnerCardTextField().getKo(index, 'ko'),
                const Divider(height: 30),
                InnerCardTextField().getFos(index),
              ],
            );
            break;

          case MyStrings.quiz:
            innerWidget = Column(
              children: [
                InnerCardTextField().getKo(index, 'ko'),
                const Divider(height: 30),
                InnerCardTextField().getFos(index),
                const SizedBox(height: 50),
                Row(
                  children: [
                    Expanded(child: InnerCardTextField().getQuizExam(label: '보기1 (정답)')),
                    const SizedBox(width: 10),
                    Expanded(child: InnerCardTextField().getQuizExam(label: '보기2')),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: InnerCardTextField().getQuizExam(label: '보기3')),
                    const SizedBox(width: 10),
                    Expanded(child: InnerCardTextField().getQuizExam(label: '보기4')),
                  ],
                ),
              ],
            );
            break;
        }

        Widget widget = Column(
          key: ValueKey(index),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                card.type == MyStrings.explain
                    ? Text('${card.type} (${Languages().getFos[explainFoIndex]})')
                    : Text(card.type),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _controller.removeCardItem(index);
                    });
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
                card.type == MyStrings.explain
                    ? TextButton(
                        onPressed: () {
                          setState(() {
                            _controller.setEditMode(id: card.id);
                          });
                        },
                        child: const Text('수정'),
                      )
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
                      child: SingleChildScrollView(child: innerWidget),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
        return widget;
      },
      growable: true,
    );
  }

  Widget getExampleList({required int summaryIndex}) {
    if (_controller.lessonSummaries[summaryIndex].examples == null) {
      _controller.lessonSummaries[summaryIndex].examples = [];
      _controller.lessonSummaries[summaryIndex].examples!.add('');
    }
    List<String> exampleList = _controller.lessonSummaries[summaryIndex].examples!;

    return ListView.builder(
      shrinkWrap: true,
      itemCount: exampleList.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: InnerCardTextField().getSummaryEx(summaryIndex: summaryIndex, exampleIndex: index),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () {
                    setState(() {
                      exampleList.removeAt(index);
                    });
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }

  Widget getSummaryCard() {
    List<LessonSummary> summaries = _controller.lessonSummaries;
    int summaryCount = 0;

    for (LessonCard card in _controller.cards) {
      if (card.type == MyStrings.subject) {
        if (summaries.length == summaryCount) {
          summaries.add(LessonSummary());
        }
        summaries[summaryCount].orderId = summaryCount;
        summaries[summaryCount].content['ko'] = card.content['ko'] ?? '';
        for (String lang in Languages().getFos) {
          summaries[summaryCount].content[lang] = card.content[lang] ?? '';
        }
        summaryCount++;
      }
    }
    int summariesLength = summaries.length;
    if (summariesLength > summaryCount) {
      for (int i = summariesLength - summaryCount; i > 0; i--) {
        summaries.removeLast();
      }
    }

    if (summaries.isNotEmpty) {
      return Column(
        children: [
          const Text(MyStrings.summary),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: cardWidth,
                  child: ListView.builder(
                      itemCount: summaries.length,
                      itemBuilder: (context, index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '[${index.toString()}]',
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 10),
                            InnerCardTextField().getSummaryKo(index),
                            const Divider(height: 30),
                            InnerCardTextField().getSummaryFos(index),
                            const SizedBox(height: 15),
                            const Text('${MyStrings.example}s)'),
                            const SizedBox(height: 10),
                            getExampleList(summaryIndex: index),
                            Align(
                                alignment: Alignment.center,
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _controller.lessonSummaries[index].examples!.add('');
                                    });
                                  },
                                  icon: const Icon(Icons.add_circle_rounded),
                                )),
                            const SizedBox(height: 20),
                          ],
                        );
                      }),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    setCards();

    return Scaffold(
      appBar: AppBar(
        title: Text('레슨카드  :  $sampleTitle'),
      ),
      body: GetBuilder<LessonStateManager>(
        builder: (controller) {
          return Column(
            children: [
              Row(
                children: [
                  MyRadioBtn().getRadioButton(
                      context: context,
                      value: MyStrings.subject,
                      groupValue: _controller.cardType,
                      f: _controller.changeCardTypeRadio()),
                  MyRadioBtn().getRadioButton(
                      context: context,
                      value: MyStrings.explain,
                      groupValue: _controller.cardType,
                      f: _controller.changeCardTypeRadio()),
                  MyRadioBtn().getRadioButton(
                      width: 200,
                      context: context,
                      value: MyStrings.repeat,
                      groupValue: _controller.cardType,
                      f: _controller.changeCardTypeRadio()),
                  MyRadioBtn().getRadioButton(
                      context: context,
                      value: MyStrings.speaking,
                      groupValue: _controller.cardType,
                      f: _controller.changeCardTypeRadio()),
                  MyRadioBtn().getRadioButton(
                      context: context,
                      value: MyStrings.quiz,
                      groupValue: _controller.cardType,
                      f: _controller.changeCardTypeRadio()),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _controller.addCardItem();
                      });
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.add),
                        SizedBox(width: 10),
                        Text('카드추가'),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Scrollbar(
                        controller: scrollController,
                        child: ReorderableListView(
                          scrollController: scrollController,
                          padding: const EdgeInsets.all(20),
                          scrollDirection: Axis.horizontal,
                          onReorder: (int oldIndex, int newIndex) {
                            setState(() {
                              _controller.reorderCardItem(oldIndex, newIndex);
                            });
                          },
                          children: cardWidgets,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: getSummaryCard(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30),
                child: ElevatedButton(
                  onPressed: () async {
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
            ],
          );
        },
      ),
    );
  }
}
