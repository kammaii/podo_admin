import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:podo_admin/common/my_html_color.dart';
import 'package:podo_admin/common/my_radio_btn.dart';
import 'package:podo_admin/screens/main_frame.dart';
import 'package:podo_admin/screens/question/question.dart';
import 'package:podo_admin/screens/question/question_state_manager.dart';
import 'package:podo_admin/screens/value/my_strings.dart';
import 'package:podo_admin/screens/writing/writing.dart';
import 'package:podo_admin/screens/writing/writing_state_manager.dart';

class QuestionDetail extends StatelessWidget {
  QuestionDetail({Key? key}) : super(key: key);

  //final WritingStateManager _controller = Get.find<WritingStateManager>();
  //final WritingStateManager _controller = Get.put(WritingStateManager()); //todo: Get.find로 바꾸기
  late Question question;
  late bool isSelected;
  final double boxSize = 1000;
  final TextEditingController questionController = TextEditingController();
  final HtmlEditorController htmlController = HtmlEditorController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('질문 상세')),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: GetBuilder<QuestionStateManager>(
          builder: (controller) {
            question = controller.questions[controller.index];
            questionController.text = question.question;
            (question.status == 1 || question.status == 3)
                ? isSelected = true
                : isSelected = false;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: controller.statusColor[question.status],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(controller.statusMap[question.status]!, textScaleFactor: 2),
                    const SizedBox(width: 20),
                    Text(
                      '(${controller.questions.indexOf(question) + 1} / ${controller.questions.length})',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Row(
                    children: [
                      SizedBox(
                        width: boxSize,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Text(' 질문', textScaleFactor: 2),
                                    const SizedBox(width: 20),
                                    Row(
                                      children: [
                                        MyRadioBtn().getRadioButton(
                                            context: context,
                                            title: '미선정',
                                            radio: controller.selectRadio,
                                            f: controller.changeSelectRadio()),
                                        MyRadioBtn().getRadioButton(
                                            context: context,
                                            title: '선정',
                                            radio: controller.selectRadio,
                                            f: controller.changeSelectRadio()),
                                        MyRadioBtn().getRadioButton(
                                            context: context,
                                            title: '게시중',
                                            radio: controller.selectRadio,
                                            f: controller.changeSelectRadio()),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        controller.index--;
                                        controller.getQuestion();
                                      },
                                      icon: const Icon(Icons.arrow_circle_left_outlined),
                                      iconSize: 30,
                                      tooltip: '이전질문',
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        controller.index++;
                                        controller.getQuestion();
                                      },
                                      icon: const Icon(Icons.arrow_circle_right_outlined),
                                      iconSize: 30,
                                      tooltip: '다음질문',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                                ),
                                child: TextField(
                                  controller: questionController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Visibility(
                              visible: isSelected,
                              child: const Text(' 답변', textScaleFactor: 2),
                            ),
                            const SizedBox(height: 10),
                            Visibility(
                              visible: isSelected,
                              child: Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    border: Border.all(),
                                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                                  ),
                                  child: HtmlEditor(
                                    controller: htmlController,
                                    htmlEditorOptions: HtmlEditorOptions(
                                        initialText: question.answer, hint: '질문에 답변하세요.'),
                                    htmlToolbarOptions: HtmlToolbarOptions(
                                      defaultToolbarButtons: [
                                        const OtherButtons(
                                            fullscreen: false,
                                            undo: false,
                                            redo: false,
                                            copy: false,
                                            paste: false,
                                            help: false),
                                      ],
                                      customToolbarButtons: [
                                        MyHtmlColor().colorButton(
                                            controller: htmlController, color: MyStrings.red),
                                        MyHtmlColor().colorButton(
                                            controller: htmlController, color: MyStrings.blue),
                                        MyHtmlColor().colorButton(
                                            controller: htmlController,
                                            color: MyStrings.black),
                                      ],
                                    ),
                                    callbacks: Callbacks(onChangeContent: (String? content) {
                                      question.answer = content;
                                    }),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(30),
                              child: Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Get.dialog(
                                      AlertDialog(
                                        content: const Text('교정을 완료하겠습니까?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Get.back();
                                            },
                                            child: const Text('아니요'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              controller.setAnswer(
                                                  questionId: question.questionId,
                                                  answer: htmlController.getText().toString());
                                              Get.offAll(const MainFrame());
                                            },
                                            child: const Text('네'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    child: Text(
                                      '저장',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: isSelected,
                        child: Row(
                          children: [
                            const SizedBox(width: 80, child: VerticalDivider(endIndent: 100)),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text('태그', textScaleFactor: 2),
                                const SizedBox(height: 20),
                                ToggleButtons(
                                  onPressed: controller.changeTagToggle(),
                                  direction: Axis.vertical,
                                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                                  selectedBorderColor: Theme.of(context).colorScheme.primary,
                                  selectedColor: Colors.white,
                                  fillColor: Theme.of(context).colorScheme.primary,
                                  color: Theme.of(context).colorScheme.primary,
                                  isSelected: controller.selectedTags,
                                  children: controller.getTagWidgets(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
