import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/common/my_textfield.dart';
import 'package:podo_admin/items/lesson_card.dart';
import 'package:podo_admin/items/lesson_summary_item.dart';
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
  late Map<String,HtmlEditorController> htmlControllers;

  Widget getRadioButton({required String value, bool isCardType = true}) {
    return SizedBox(
      width: 160,
      child: ListTile(
        title: Text(value),
        leading: Radio(
          activeColor: primaryColor,
          value: value,
          groupValue: isCardType ? _controller.cardType : _controller.quizQuestionLang,
          onChanged: (String? value) {
            isCardType ? _controller.changeCardType(value) : _controller.changeQuizQuestionLang(value);
          },
        ),
      ),
    );
  }

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
            htmlControllers[card.uniqueId] = controller;
            innerWidget = HtmlEditor(
              controller: controller,
              htmlEditorOptions: const HtmlEditorOptions(
                hint: MyStrings.explain,
              ),
              htmlToolbarOptions: const HtmlToolbarOptions(
                toolbarType: ToolbarType.nativeGrid,
                toolbarPosition: ToolbarPosition.belowEditor,
                defaultToolbarButtons: [
                  StyleButtons(),
                  ColorButtons(highlightColor: false),
                  ListButtons(listStyles: false),
                  InsertButtons(),
                ]
              ),
              callbacks: Callbacks(
                onChangeContent: (String? content) {
                  print(content);
                  card.explain = content;
                }
              ),
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
                    primary: primaryColor,
                    onPrimary: onPrimaryColor,
                  ),
                  child: const Text(MyStrings.makeSpeakingCard),
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
                            getRadioButton(value: MyStrings.korean, isCardType: false),
                            getRadioButton(value: MyStrings.english, isCardType: false),
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

          case MyStrings.summary:
            int subjectCount = 1;
            List<LessonSummaryItem> items = [];
            List<Widget> children = [];
            for (LessonCard card in _controller.cardItems) {
              if (card.type == MyStrings.subject) {
                children.add(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subjectCount.toString()),
                    InnerCardTextField().getKr(index),
                    const SizedBox(height: 10),
                    InnerCardTextField().getEn(index),
                    const SizedBox(height: 10),
                    InnerCardTextField().getExplain(index),
                    const SizedBox(height: 10),
                    const Text('${MyStrings.example}s)'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: MyTextField().getTextField(
                            label: MyStrings.example,
                            autoFocus: true,
                            onChangedFunction: (text) {
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: MyTextField().getTextField(
                            label: MyStrings.audio,
                            autoFocus: true,
                            onChangedFunction: (text) {
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(onPressed: (){}, icon: Icon(Icons.volume_up_rounded, color: primaryColor)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Align(alignment: Alignment.center, child: IconButton(onPressed: (){}, icon: Icon(Icons.add_circle_rounded, color: primaryColor))),
                    const SizedBox(height: 20),
                  ],
                ));
                subjectCount++;
              }
            }
            innerWidget = SingleChildScrollView(
              child: Column(
                children: children,
              ),
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
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  color: card.type == MyStrings.summary ? surfaceVariantColor : backgroundColor,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: 350,
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

  @override
  Widget build(BuildContext context) {
    primaryColor = Theme.of(context).colorScheme.primary;
    onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    backgroundColor = Theme.of(context).colorScheme.background;
    surfaceVariantColor = Theme.of(context).colorScheme.surfaceVariant;
    htmlControllers = {};
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
                  getRadioButton(value: MyStrings.subject),
                  getRadioButton(value: MyStrings.explain),
                  getRadioButton(value: MyStrings.repeat),
                  getRadioButton(value: MyStrings.speaking),
                  getRadioButton(value: MyStrings.quiz),
                  getRadioButton(value: MyStrings.summary),
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
                        Text(MyStrings.add),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
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
                padding: const EdgeInsets.all(30),
                child: ElevatedButton(
                  onPressed: () async {
                    for (LessonCard card in _controller.cardItems) {
                      //todo: save contents to firestore
                      Database().saveLessonCard(card);
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      MyStrings.save,
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
