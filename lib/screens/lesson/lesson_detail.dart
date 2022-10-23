import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:podo_admin/common/my_html_color.dart';
import 'package:podo_admin/common/my_radio_btn.dart';
import 'package:podo_admin/items/lesson_card.dart';
import 'package:podo_admin/items/lesson_summary.dart';
import 'package:podo_admin/screens/lesson/inner_card_textfield.dart';
import 'package:podo_admin/screens/lesson/lesson_state_manager.dart';
import 'package:podo_admin/screens/value/my_strings.dart';

class LessonDetail extends StatelessWidget {
  //const LessonDetail({required this.lessonTitle, Key? key}) : super(key: key);
  LessonDetail({Key? key}) : super(key: key);

  //final LessonTitle lessonTitle;
  //final LessonStateManager _controller = Get.find<LessonStateManager>();
  final LessonStateManager _controller = Get.put(LessonStateManager());
  late List<Widget> cards;
  final ScrollController scrollController = ScrollController();
  late final Color primaryColor;
  late final Color onPrimaryColor;
  late final Color backgroundColor;
  late final Color surfaceVariantColor;
  final double cardWidth = 350;
  late final BuildContext _context;

  void setCards() {
    cards = [];
    cards = List<Widget>.generate(
      _controller.cardItems.length,
      (index) {
        LessonCard card = _controller.cardItems[index];
        Widget? innerWidget;
        switch (card.type) {
          case MyStrings.subject:
            innerWidget = Column(
              children: [
                InnerCardTextField().getKr(index),
                const SizedBox(height: 20),
                InnerCardTextField().getEn(index),
              ],
            );
            break;

          case MyStrings.explain:
            HtmlEditorController controller = HtmlEditorController();
            String explain = card.explain ?? '';
            innerWidget = Column(
              children: [
                if (_controller.isEditMode.containsKey(card.uniqueId) &&
                    _controller.isEditMode[card.uniqueId]!)
                  HtmlEditor(
                    controller: controller,
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
                        MyHtmlColor().colorButton(controller: controller, color: MyStrings.red),
                        MyHtmlColor().colorButton(controller: controller, color: MyStrings.blue),
                        MyHtmlColor().colorButton(controller: controller, color: MyStrings.black),
                      ],
                    ),
                    callbacks: Callbacks(onChangeContent: (String? content) {
                      card.explain = content;
                    }),
                  )
                else
                  Text(explain)
              ],
            );
            break;

          case MyStrings.repeat:
            innerWidget = Column(
              children: [
                InnerCardTextField().getKr(index),
                const SizedBox(height: 20),
                InnerCardTextField().getPronun(index),
                const SizedBox(height: 20),
                InnerCardTextField().getEn(index),
                const SizedBox(height: 20),
                InnerCardTextField().getAudio(index),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _controller.cardType = MyStrings.speaking;
                    _controller.addCardItem();
                    setCards();
                    _controller.update();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: onPrimaryColor,
                    backgroundColor: primaryColor,
                  ),
                  child: const Text('말하기카드만들기'),
                )
              ],
            );
            break;

          case MyStrings.speaking:
            innerWidget = Column(
              children: [
                InnerCardTextField().getKr(index),
                const SizedBox(height: 20),
                InnerCardTextField().getEn(index),
                const SizedBox(height: 20),
                InnerCardTextField().getAudio(index),
              ],
            );
            break;

          case MyStrings.quiz:
            innerWidget = Column(
              children: [
                GetBuilder<LessonStateManager>(
                  builder: (controller) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            MyRadioBtn().getRadioButton(
                                context: _context,
                                title: MyStrings.korean,
                                radio: _controller.quizQuestionLang,
                                f: _controller.changeQuizQuestionLangRadio()),
                            MyRadioBtn().getRadioButton(
                                context: _context,
                                title: MyStrings.english,
                                radio: _controller.quizQuestionLang,
                                f: _controller.changeQuizQuestionLangRadio()),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _controller.quizQuestionLang == MyStrings.korean
                            ? InnerCardTextField()
                                .getKr(index, lab: '${MyStrings.question} in ${MyStrings.korean}')
                            : InnerCardTextField()
                                .getEn(index, lab: '${MyStrings.question} in ${MyStrings.english}'),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 50),
                Row(
                  children: [
                    Expanded(child: InnerCardTextField().getQuizExam(label: MyStrings.ex1)),
                    const SizedBox(width: 10),
                    Expanded(child: InnerCardTextField().getQuizExam(label: MyStrings.ex2)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: InnerCardTextField().getQuizExam(label: MyStrings.ex3)),
                    const SizedBox(width: 10),
                    Expanded(child: InnerCardTextField().getQuizExam(label: MyStrings.ex4)),
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
                Text(card.type),
                IconButton(
                  onPressed: () {
                    _controller.removeCardItem(index);
                    setCards();
                    _controller.update();
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
                card.type == MyStrings.explain
                    ? TextButton(
                        onPressed: () {
                          _controller.setEditMode(id: card.uniqueId);
                          setCards();
                          _controller.update();
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
                      child: innerWidget,
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

  Widget getExampleList({required int subjectIndex}) {
    List<String> list = _controller.lessonSummary.contents[subjectIndex].examples;
    if (list.isEmpty) {
      list.add('');
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: list.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: InnerCardTextField().getSummary(
                        textValue: list[index],
                        lab: '${MyStrings.example}$index',
                        function: (text) {
                          list[index] = text;
                        })),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () {
                    list.removeAt(index);
                    _controller.update();
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
            Row(
              children: [
                Text(' ${_controller.lessonId}_${MyStrings.summary}_${subjectIndex}_$index'),
                IconButton(
                  onPressed: () {
                    //todo: 오디오 재생
                  },
                  icon: Icon(Icons.volume_up_rounded, color: primaryColor),
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
    List<LessonSummaryItem> items = _controller.lessonSummary.contents;
    int subjectCardCount = 0;

    for (LessonCard card in _controller.cardItems) {
      if (card.type == MyStrings.subject) {
        String kr = card.kr ?? '';
        String en = card.en ?? '';
        if (items.length > subjectCardCount) {
          items[subjectCardCount].subjectKr = kr;
          items[subjectCardCount].subjectEn = en;
        } else {
          items.add(LessonSummaryItem(subjectKr: kr, subjectEn: en));
        }
        subjectCardCount++;
      }
    }
    int itemsLength = items.length;
    if (itemsLength > subjectCardCount) {
      for (int i = itemsLength - subjectCardCount; i > 0; i--) {
        items.removeLast();
      }
    }

    return items.isNotEmpty
        ? Column(
            children: [
              const Text(MyStrings.summary),
              Expanded(
                child: Card(
                  color: surfaceVariantColor,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: cardWidth,
                      child: ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            LessonSummaryItem item = items[index];

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '[${index.toString()}]',
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(height: 10),
                                InnerCardTextField().getSummary(
                                    textValue: item.subjectKr,
                                    lab: MyStrings.korean,
                                    function: (text) {
                                      item.subjectKr = text;
                                    }),
                                const SizedBox(height: 10),
                                InnerCardTextField().getSummary(
                                    textValue: item.subjectEn,
                                    lab: MyStrings.english,
                                    function: (text) {
                                      item.subjectEn = text;
                                    }),
                                const SizedBox(height: 10),
                                InnerCardTextField().getSummary(
                                    textValue: item.explain,
                                    lab: MyStrings.explain,
                                    function: (text) {
                                      item.explain = text;
                                    }),
                                const SizedBox(height: 15),
                                const Text('${MyStrings.example}s)'),
                                const SizedBox(height: 10),
                                getExampleList(subjectIndex: index),
                                Align(
                                    alignment: Alignment.center,
                                    child: IconButton(
                                      onPressed: () {
                                        item.examples.add('');
                                        _controller.update();
                                      },
                                      icon: Icon(Icons.add_circle_rounded, color: primaryColor),
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
          )
        : const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    primaryColor = Theme.of(context).colorScheme.primary;
    onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    backgroundColor = Theme.of(context).colorScheme.background;
    surfaceVariantColor = Theme.of(context).colorScheme.surfaceVariant;
    setCards();

    return Scaffold(
      appBar: AppBar(
        //title: Text('${lessonTitle.title} / ${lessonTitle.category}'),
        title: const Text('lesson detail'),
      ),
      body: GetBuilder<LessonStateManager>(
        builder: (controller) {
          return Column(
            children: [
              Row(
                children: [
                  MyRadioBtn().getRadioButton(
                      context: context,
                      title: MyStrings.subject,
                      radio: _controller.cardType,
                      f: _controller.changeCardTypeRadio()),
                  MyRadioBtn().getRadioButton(
                      context: context,
                      title: MyStrings.explain,
                      radio: _controller.cardType,
                      f: _controller.changeCardTypeRadio()),
                  MyRadioBtn().getRadioButton(
                      context: context,
                      title: MyStrings.repeat,
                      radio: _controller.cardType,
                      f: _controller.changeCardTypeRadio()),
                  MyRadioBtn().getRadioButton(
                      context: context,
                      title: MyStrings.speaking,
                      radio: _controller.cardType,
                      f: _controller.changeCardTypeRadio()),
                  MyRadioBtn().getRadioButton(
                      context: context,
                      title: MyStrings.quiz,
                      radio: _controller.cardType,
                      f: _controller.changeCardTypeRadio()),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      _controller.addCardItem();
                      setCards();
                      _controller.update();
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
                            _controller.reorderCardItem(oldIndex, newIndex);
                            setCards();
                            _controller.update();
                          },
                          children: cards,
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
                    for (LessonSummaryItem item in _controller.lessonSummary.contents) {
                      print('kr : ${item.subjectKr}');
                      print('en : ${item.subjectEn}');
                      print('explain : ${item.explain}');
                      for (String example in item.examples) {
                        print(example);
                      }
                    }

                    // for (LessonCard card in _controller.cardItems) {
                    //   todo: save contents to firestore
                    //   Database().saveLessonCard(card);
                    //   if (card.type == MyStrings.summary) {
                    //   }
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
