import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/common/gpt_translator.dart';
import 'package:podo_admin/common/languages.dart';
import 'package:podo_admin/common/my_html_color.dart';
import 'package:podo_admin/common/my_radio_btn.dart';
import 'package:podo_admin/common/my_textfield.dart';
import 'package:podo_admin/screens/lesson/inner_card_textfield.dart';
import 'package:podo_admin/screens/lesson/lesson.dart';
import 'package:podo_admin/screens/lesson/lesson_card.dart';
import 'package:podo_admin/screens/lesson/lesson_state_manager.dart';
import 'package:podo_admin/screens/lesson/lesson_summary.dart';
import 'package:podo_admin/screens/writing/writing_question.dart';
import 'package:podo_admin/screens/value/my_strings.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LessonCardMain extends StatefulWidget {
  const LessonCardMain({Key? key}) : super(key: key);

  @override
  State<LessonCardMain> createState() => _LessonCardMainState();
}

class _LessonCardMainState extends State<LessonCardMain> {
  final _controller = Get.find<LessonStateManager>();
  List<Widget> cardWidgets = [];
  final ScrollController scrollController = ScrollController();
  final double cardWidth = 350;
  late List<Map<String, TextEditingController>> writingControllers;
  int explainFoIndex = 0;
  int detailFoIndex = 0;
  final htmlEditorController = HtmlEditorController();
  Lesson lesson = Get.arguments;
  final LESSONS = 'Lessons';
  final LESSON_CARDS = 'LessonCards';
  final LESSON_SUMMARIES = 'LessonSummaries';
  final WRITING_QUESTIONS = 'WritingQuestions';
  final ORDER_ID = 'orderId';
  final KO = 'ko';
  final FO = 'fo';
  final PRONUN = 'pronun';

  @override
  void initState() {
    super.initState();
    _controller.snapshots = {LESSON_CARDS: [], LESSON_SUMMARIES: [], WRITING_QUESTIONS: []};
    _controller.cards = [];
    _controller.lessonSummaries = [];
    _controller.writingQuestions = [];
    _controller.futureList = Future.wait([
      Database().getDocs(collection: '$LESSONS/${lesson.id}/$LESSON_CARDS', orderBy: ORDER_ID, descending: false),
      Database()
          .getDocs(collection: '$LESSONS/${lesson.id}/$LESSON_SUMMARIES', orderBy: ORDER_ID, descending: false),
      Database()
          .getDocs(collection: '$LESSONS/${lesson.id}/$WRITING_QUESTIONS', orderBy: ORDER_ID, descending: false)
    ]);
  }

  Widget getDetailContent(LessonCard card) {
    String language = Languages().getFos[detailFoIndex];
    card.detailContent ??= {};
    String detailContent = card.detailContent?[language] ?? '';

    if ((_controller.isEditMode.containsKey(card.id) && _controller.isEditMode[card.id]!)) {
      htmlEditorController.setText(detailContent);
      return Row(
        children: [
          IconButton(
              onPressed: () {
                setState(() {
                  detailFoIndex--;
                });
              },
              icon: const Icon(Icons.arrow_back_ios_rounded),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints()),
          Expanded(
            child: HtmlEditor(
              controller: htmlEditorController,
              htmlEditorOptions: HtmlEditorOptions(hint: MyStrings.explain, initialText: detailContent),
              htmlToolbarOptions: HtmlToolbarOptions(
                toolbarType: ToolbarType.nativeGrid,
                defaultToolbarButtons: [
                  const StyleButtons(),
                  const ListButtons(listStyles: false),
                  const InsertButtons(),
                  const OtherButtons(
                      fullscreen: false, undo: false, redo: false, copy: false, paste: false, help: false),
                ],
                customToolbarButtons: [
                  MyHtmlColor().colorButton(controller: htmlEditorController, color: MyStrings.red),
                  MyHtmlColor().colorButton(controller: htmlEditorController, color: MyStrings.blue),
                  MyHtmlColor().colorButton(controller: htmlEditorController, color: MyStrings.black),
                ],
              ),
              callbacks: Callbacks(onChangeContent: (String? content) {
                if (language == Languages().getFos[detailFoIndex]) {
                  card.detailContent![language] = content!;
                }
              }),
            ),
          ),
          IconButton(
              onPressed: () {
                setState(() {
                  detailFoIndex++;
                });
              },
              icon: const Icon(Icons.arrow_forward_ios_rounded),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints()),
        ],
      );
    } else {
      return Text(detailContent);
    }
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
                InnerCardTextField().getKo(index, KO),
              ],
            );
            break;

          case MyStrings.mention:
            if (detailFoIndex >= Languages().getFos.length) {
              detailFoIndex = 0;
            } else if (detailFoIndex < 0) {
              detailFoIndex = Languages().getFos.length - 1;
            }
            innerWidget = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InnerCardTextField().getFos(index),
                const Divider(height: 30),
                Row(
                  children: [
                    const Text('detail title', style: TextStyle(color: Colors.grey)),
                    TextButton(
                        onPressed: () {
                          if (_controller.cards[index].detailTitle != null) {
                            GPTTranslator()
                                .getTranslations(_controller.cards[index].detailTitle!)
                                .then((value) => setState(() {}));
                          }
                        },
                        child: const Text('번역'))
                  ],
                ),
                const SizedBox(height: 5),
                InnerCardTextField().getDetailTitles(index),
                Row(
                  children: [
                    Text('detail content (${Languages().getFos[detailFoIndex]})',
                        style: const TextStyle(color: Colors.grey)),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _controller.setEditMode(id: card.id);
                        });
                      },
                      child: const Text('수정'),
                    )
                  ],
                ),
                const SizedBox(height: 5),
                getDetailContent(card),
                const Divider(height: 30),
                const Text('optional', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 5),
                InnerCardTextField().getVideo(index),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(child: InnerCardTextField().getClip(index, lab: 'clipStart')),
                    const SizedBox(width: 5),
                    Expanded(child: InnerCardTextField().getClip(index, lab: 'clipEnd')),
                  ],
                ),
                const SizedBox(height: 5),
                InnerCardTextField().getAudio(index),
                const SizedBox(height: 5),
                InnerCardTextField().getKo(index, KO),
              ],
            );
            break;

          case MyStrings.tip:
            innerWidget = Column(
              children: [
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
            String explain = card.content[language] ?? '';

            if ((_controller.isEditMode.containsKey(card.id) && _controller.isEditMode[card.id]!)) {
              htmlEditorController.setText(explain);
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
                              fullscreen: false, undo: false, redo: false, copy: false, paste: false, help: false),
                        ],
                        customToolbarButtons: [
                          MyHtmlColor().colorButton(controller: htmlEditorController, color: MyStrings.red),
                          MyHtmlColor().colorButton(controller: htmlEditorController, color: MyStrings.blue),
                          MyHtmlColor().colorButton(controller: htmlEditorController, color: MyStrings.black),
                        ],
                      ),
                      callbacks: Callbacks(onChangeContent: (String? content) {
                        if (language == Languages().getFos[explainFoIndex]) {
                          card.content[language] = content!;
                        }
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
                InnerCardTextField().getKo(index, KO),
                const SizedBox(height: 5),
                InnerCardTextField().getKo(index, PRONUN),
                const Divider(height: 30),
                InnerCardTextField().getFos(index),
                const Divider(height: 30),
                InnerCardTextField().getAudio(index),
                const SizedBox(height: 20),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _controller.copyRepeat(card);
                        });
                      },
                      child: const Text('복사하기'),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _controller.makeQuiz(card);
                        });
                      },
                      child: const Text('퀴즈만들기'),
                    ),
                  ],
                )
              ],
            );
            break;

          case MyStrings.quiz:
            innerWidget = Column(
              children: [
                InnerCardTextField().getKo(index, KO),
                const Divider(height: 30),
                InnerCardTextField().getFos(index),
                const SizedBox(height: 50),
                Row(
                  children: [
                    Expanded(child: InnerCardTextField().getQuizExam(index: index, label: 'ex1')),
                    const SizedBox(width: 10),
                    Expanded(child: InnerCardTextField().getQuizExam(index: index, label: 'ex2')),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(child: InnerCardTextField().getQuizExam(index: index, label: 'ex3')),
                    const SizedBox(width: 10),
                    Expanded(child: InnerCardTextField().getQuizExam(index: index, label: 'ex4')),
                  ],
                ),
                const Divider(height: 30),
                InnerCardTextField().getAudio(index),
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
                Text('$index  '),
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
                card.type != MyStrings.subject && card.type != MyStrings.explain
                    ? TextButton(
                        onPressed: () {
                          GPTTranslator()
                              .getTranslations(_controller.cards[index].content)
                              .then((value) => setState(() {}));
                        },
                        child: const Text('번역'))
                    : const SizedBox.shrink(),
              ],
            ),
            card.type == MyStrings.explain
                ? const Text('** 붙여넣기 시 <>클릭하고 \'Ctrl+Shift+V\', <p>태그로 감싸기 확인 **',
                    style: TextStyle(
                      color: Colors.red,
                      backgroundColor: Colors.yellow,
                      fontWeight: FontWeight.bold,
                    ))
                : const SizedBox.shrink(),
            card.type == MyStrings.quiz
                ? const Text('** ko와 fo중 하나만 입력 / 정답은 ex1에 입력 **',
                    style: TextStyle(
                      color: Colors.red,
                      backgroundColor: Colors.yellow,
                      fontWeight: FontWeight.bold,
                    ))
                : const SizedBox.shrink(),
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
            const SizedBox(height: 20),
            GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: card.id));
                  Get.snackbar('아이디가 클립보드에 저장되었습니다.', card.id, snackPosition: SnackPosition.BOTTOM);
                },
                child: Text(card.id, style: const TextStyle(color: Colors.grey))),
          ],
        );
        return widget;
      },
      growable: true,
    );
  }

  Widget getExampleList({required int summaryIndex}) {
    List<dynamic> exampleList = _controller.lessonSummaries[summaryIndex].examples;
    if (exampleList.isNotEmpty) {
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
                      exampleList.removeAt(index);
                      _controller.update();
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
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget getSummaryDialog() {
    List<LessonSummary> summaries = _controller.lessonSummaries;
    if (summaries.isEmpty) {
      summaries.add(LessonSummary(0));
    }

    return GetBuilder<LessonStateManager>(
      builder: (controller) {
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(MyStrings.summary, style: TextStyle(fontSize: 15)),
                      const SizedBox(width: 10),
                      TextButton(
                          onPressed: () {
                            summaries.add(LessonSummary(summaries.length));
                            controller.update();
                          },
                          child: const Text('추가')),
                    ],
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Database().runLessonBatch(lessonId: lesson.id, collection: LESSON_SUMMARIES);
                        Get.back();
                      },
                      child: const Text('저장')),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SizedBox(
                  width: cardWidth,
                  child: ListView.builder(
                      itemCount: summaries.length,
                      itemBuilder: (context, index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '[${index.toString()}]',
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 10),
                                TextButton(
                                    onPressed: () {
                                      Get.dialog(AlertDialog(
                                        title: const Text('삭제하겠습니까?'),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                summaries.removeAt(index);
                                                for (int i = 0; i < summaries.length; i++) {
                                                  summaries[i].orderId = i;
                                                }
                                                controller.update();
                                                Get.back();
                                              },
                                              child: const Text('네', style: TextStyle(color: Colors.red))),
                                          TextButton(
                                              onPressed: () {
                                                Get.back();
                                              },
                                              child: const Text('아니오')),
                                        ],
                                      ));
                                    },
                                    child: const Text('삭제')),
                              ],
                            ),
                            const SizedBox(height: 30),
                            InnerCardTextField().getSummaryKo(index),
                            const Divider(height: 30),
                            Row(
                              children: [
                                TextButton(
                                    onPressed: () {
                                      GPTTranslator()
                                          .getTranslations(_controller.lessonSummaries[index].content)
                                          .then((value) => _controller.update());
                                    },
                                    child: const Text('번역'))
                              ],
                            ),
                            const SizedBox(height: 10),
                            InnerCardTextField().getSummaryFos(index),
                            const SizedBox(height: 20),
                            TextButton(
                                onPressed: () {
                                  _controller.lessonSummaries[index].examples.add(' ');
                                  controller.update();
                                },
                                child: const Text('예문추가')),
                            const SizedBox(height: 20),
                            getExampleList(summaryIndex: index),
                            const SizedBox(height: 30),
                          ],
                        );
                      }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget getWritingDialog() {
    writingControllers = [];
    for (int i = 0; i < _controller.writingQuestions.length; i++) {
      writingControllers.add({KO: TextEditingController(), FO: TextEditingController()});
    }
    _controller.selectedLanguage = Languages().getFos[0];

    return GetBuilder<LessonStateManager>(
      builder: (_) {
        if(_controller.writingQuestions.isEmpty) {
          _controller.writingQuestions.add(WritingQuestion());
          _controller.writingQuestions.add(WritingQuestion());
          writingControllers.add({KO: TextEditingController(), FO: TextEditingController()});
          writingControllers.add({KO: TextEditingController(), FO: TextEditingController()});
        }
        return SizedBox(
          width: 1500,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('쓰기타이틀', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 20),
                        TextButton(
                          onPressed: () {
                            _controller.writingQuestions.add(WritingQuestion());
                            writingControllers.add({KO: TextEditingController(), FO: TextEditingController()});
                            _controller.update();
                          },
                          child: const Text('추가'),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Database().runLessonBatch(lessonId: lesson.id, collection: WRITING_QUESTIONS);
                        Get.back();
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Text('저장', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_controller.writingQuestions.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _controller.writingQuestions.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: SizedBox(
                            width: 400,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        _controller.writingQuestions.removeAt(index);
                                        for (int i = 0; i < _controller.writingQuestions.length; i++) {
                                          _controller.writingQuestions[i].orderId = i;
                                        }
                                        writingControllers.removeAt(index);
                                        _controller.update();
                                      },
                                      icon: const Icon(
                                        Icons.remove_circle_outline_rounded,
                                        size: 25,
                                        color: Colors.red,
                                      )),
                                  Row(
                                    children: [
                                      Text('${index.toString()}. '),
                                      const SizedBox(width: 20),
                                      DropdownButton(
                                          value:
                                              _controller.writingLevel[_controller.writingQuestions[index].level],
                                          icon: const Icon(Icons.arrow_drop_down_outlined),
                                          items: _controller.writingLevel
                                              .map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem(value: value, child: Text(value));
                                          }).toList(),
                                          onChanged: (value) {
                                            _controller.writingQuestions[index].level =
                                                _controller.writingLevel.indexOf(value.toString());
                                            _controller.update();
                                          }),
                                    ],
                                  ),
                                  MyTextField().getTextField(
                                      controller: TextEditingController(
                                          text: _controller.writingQuestions[index].title[KO]),
                                      label: KO,
                                      fn: (String? value) {
                                        _controller.writingQuestions[index].title[KO] = value!;
                                      }),
                                  const SizedBox(height: 20),
                                  TextButton(
                                      onPressed: () {
                                        GPTTranslator()
                                            .getTranslations(_controller.writingQuestions[index].title)
                                            .then((value) => _controller.update());
                                      },
                                      child: const Text('번역')),
                                  const SizedBox(height: 10),
                                  Expanded(child: InnerCardTextField().getWritingQuestionFos(index)),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('레슨카드  ( ${lesson.title[KO]} : ${lesson.id.substring(0, 8)})'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            GetBuilder<LessonStateManager>(
              builder: (_) {
                return Row(
                  children: [
                    MyRadioBtn().getRadioButton(
                        context: context,
                        value: MyStrings.subject,
                        groupValue: _controller.cardType,
                        f: _controller.changeCardTypeRadio()),
                    MyRadioBtn().getRadioButton(
                        context: context,
                        value: MyStrings.mention,
                        groupValue: _controller.cardType,
                        f: _controller.changeCardTypeRadio()),
                    MyRadioBtn().getRadioButton(
                        context: context,
                        value: MyStrings.tip,
                        groupValue: _controller.cardType,
                        f: _controller.changeCardTypeRadio()),
                    MyRadioBtn().getRadioButton(
                        context: context,
                        value: MyStrings.explain,
                        groupValue: _controller.cardType,
                        f: _controller.changeCardTypeRadio()),
                    MyRadioBtn().getRadioButton(
                        context: context,
                        value: MyStrings.repeat,
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
                          _controller.cards.add(LessonCard());
                        });
                      },
                      child: Row(
                        children: const [
                          Icon(Icons.add),
                          SizedBox(width: 10),
                          Text('카드추가'),
                        ],
                      ),
                    ),
                    const Expanded(child: SizedBox.shrink()),
                    ElevatedButton(
                      onPressed: () {
                        Get.dialog(AlertDialog(
                          content: getSummaryDialog(),
                        ));
                      },
                      child: const Text('요약보기'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        Get.dialog(AlertDialog(
                          content: getWritingDialog(),
                        ));
                      },
                      child: const Text('쓰기보기'),
                    ),
                  ],
                );
              },
            ),
            Expanded(
              child: FutureBuilder(
                future: _controller.futureList,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData && snapshot.connectionState != ConnectionState.waiting) {
                    if (_controller.cards.isEmpty) {
                      for (dynamic snapshot in snapshot.data[0]) {
                        LessonCard card = LessonCard.fromJson(snapshot);
                        _controller.snapshots[LESSON_CARDS]!.add(card);
                        _controller.cards.add(LessonCard.fromJson(snapshot));
                      }
                      for (dynamic snapshot in snapshot.data[1]) {
                        LessonSummary summary = LessonSummary.fromJson(snapshot);
                        _controller.snapshots[LESSON_SUMMARIES]!.add(summary);
                        _controller.lessonSummaries.add(summary);
                      }
                      for (dynamic snapshot in snapshot.data[2]) {
                        WritingQuestion question = WritingQuestion.fromJson(snapshot);
                        _controller.snapshots[WRITING_QUESTIONS]!.add(question);
                        _controller.writingQuestions.add(question);
                      }
                    }
                    setCards();
                    if (_controller.cards.isEmpty) {
                      return const Center(child: Text('카드가 없습니다.'));
                    } else {
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('마지막카드No: ${_controller.cards.length-1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
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
                        ],
                      );
                    }
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30),
              child: ElevatedButton(
                onPressed: () {
                  if (_controller.cards.isNotEmpty) {
                    Database().runLessonBatch(lessonId: lesson.id, collection: LESSON_CARDS);
                  }
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
      ),
    );
  }
}
