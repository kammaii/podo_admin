import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/common/my_html_color.dart';
import 'package:podo_admin/common/my_radio_btn.dart';
import 'package:podo_admin/screens/question/question.dart';
import 'package:podo_admin/screens/question/question_state_manager.dart';
import 'package:podo_admin/screens/value/my_strings.dart';

class QuestionDetail extends StatelessWidget {
  QuestionDetail({Key? key}) : super(key: key);

  late Question question;
  final double boxSize = 1000;
  final TextEditingController questionController = TextEditingController();
  final HtmlEditorController htmlController = HtmlEditorController();

  saveDialog() {
    bool isChecked = Get.find<QuestionStateManager>().isChecked;
    Get.dialog(
      RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: (event) {
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.enter) {
              runSave(isChecked);
            }
          }
        },
        child: AlertDialog(
          content: isChecked ? const Text('전체 질문을 저장 하겠습니까?') : const Text('이 질문만 저장 하겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('아니요'),
            ),
            TextButton(
              onPressed: () {
                runSave(isChecked);
              },
              child: const Text('네'),
            ),
          ],
        ),
      ),
    );
  }

  runSave(bool isChecked) async {
    Get.back();
    Get.defaultDialog(title: '저장중', content: const Center(child: CircularProgressIndicator()));
    if (isChecked) {
      for (Question question in Get.find<QuestionStateManager>().questions) {
        await Database().updateQuestion(question: question);
      }
    } else {
      await Database().updateQuestion(question: question);
    }
    Get.back();
    Get.snackbar('저장을 완료했습니다.', '');
  }

  @override
  Widget build(BuildContext context) {
    Get.find<QuestionStateManager>();

    return Scaffold(
      appBar: AppBar(title: const Text('질문_상세')),
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: (event) {
          QuestionStateManager controller = Get.find<QuestionStateManager>();
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              controller.changeQuestionIndex(isNext: false);
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              controller.changeQuestionIndex(isNext: true);
            } else if (event.logicalKey == LogicalKeyboardKey.enter) {
              saveDialog();
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: GetBuilder<QuestionStateManager>(
            builder: (controller) {
              question = controller.questions[controller.questionIndex];
              controller.setQuestionOptions();
              questionController.text = question.question;
              htmlController.clear();
              if (question.answer != null) {
                htmlController.setText(question.answer!);
              }

              Widget getRadioBtn(String title) {
                return MyRadioBtn().getRadioButton(
                  context: context,
                  value: title,
                  groupValue: controller.statusRadio,
                  f: controller.changeStatusRadio(),
                );
              }

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
                      const SizedBox(width: 20),
                      Text('( ${question.userEmail} )'),
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
                                          getRadioBtn('미선정'),
                                          getRadioBtn('선정'),
                                          getRadioBtn('게시중'),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          Get.find<QuestionStateManager>().changeQuestionIndex(isNext: false);
                                        },
                                        icon: const Icon(Icons.arrow_circle_left_outlined),
                                        iconSize: 30,
                                        tooltip: '이전질문',
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          Get.find<QuestionStateManager>().changeQuestionIndex(isNext: true);
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
                                  child: GetBuilder<QuestionStateManager>(
                                    builder: (controller) {
                                      return TextField(
                                        controller: questionController,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                        onChanged: (value) {
                                          question.question = value.toString();
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Visibility(
                                visible: controller.isSelectedQuestion,
                                child: Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(' 답변', textScaleFactor: 2),
                                      const SizedBox(height: 10),
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            border: Border.all(),
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                          ),
                                          child: GetBuilder<QuestionStateManager>(
                                            builder: (controller) {
                                              return HtmlEditor(
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
                                                        controller: htmlController, color: MyStrings.black),
                                                  ],
                                                ),
                                                callbacks: Callbacks(onChangeContent: (String? content) {
                                                  question.answer = content;
                                                }),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(30),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        saveDialog();
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                        child: Text(
                                          '저장',
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Checkbox(
                                      activeColor: Theme.of(context).colorScheme.inversePrimary,
                                      value: controller.isChecked,
                                      onChanged: (value) {
                                        controller.isChecked = value!;
                                        controller.update();
                                      },
                                    ),
                                    const Text('전체'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: controller.isSelectedQuestion,
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
      ),
    );
  }
}
