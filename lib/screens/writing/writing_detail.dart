import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:podo_admin/common/my_html_color.dart';
import 'package:podo_admin/screens/main_frame.dart';
import 'package:podo_admin/screens/value/my_strings.dart';
import 'package:podo_admin/screens/writing/writing.dart';
import 'package:podo_admin/screens/writing/writing_state_manager.dart';

class WritingDetail extends StatelessWidget {
  WritingDetail({Key? key}) : super(key: key);

  late Writing writing;
  HtmlEditorController htmlController = HtmlEditorController();

  completeCorrection() {
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
              Get.find<WritingStateManager>().setCorrection(
                  writingId: writing.writingId,
                  correction: htmlController.getText().toString());
              Get.offAll(const MainFrame());
            },
            child: const Text('네'),
          ),
        ],
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    const double boxSize = 1000;

    return Scaffold(
      appBar: AppBar(title: const Text('교정_상세')),
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: (event) {
          WritingStateManager controller = Get.find<WritingStateManager>();
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              controller.getWriting(isNext: false);
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              controller.getWriting(isNext: true);
            } else if (event.logicalKey == LogicalKeyboardKey.enter) {
              completeCorrection();
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SizedBox(
            width: boxSize,
            child: GetBuilder<WritingStateManager>(
              builder: (controller) {
                writing = controller.writings[controller.writingIndex];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: controller.statusColor[writing.status],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(controller.statusMap[writing.status]!, textScaleFactor: 2),
                        const SizedBox(width: 20),
                        Text(
                          '(남은 교정 수 : ${controller.writings.length})',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(writing.writingTitle, textScaleFactor: 2),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                writing.status == 0 ? controller.getWriting(isNext: false) : null;
                              },
                              icon: const Icon(Icons.arrow_circle_left_outlined),
                              iconSize: 30,
                              color: writing.status == 0 ? Colors.black : Colors.grey,
                              tooltip: '이전교정',
                            ),
                            IconButton(
                              onPressed: () {
                                writing.status == 0 ? controller.getWriting(isNext: true) : null;
                              },
                              icon: const Icon(Icons.arrow_circle_right_outlined),
                              iconSize: 30,
                              color: writing.status == 0 ? Colors.black : Colors.grey,
                              tooltip: '다음교정',
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Container(
                        width: boxSize,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Text(writing.userWriting),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(' 교정하기', textScaleFactor: 2),
                        TextButton(
                          onPressed: () {
                            Get.dialog(
                              AlertDialog(
                                content: const Text('교정불가로 체크하겠습니까?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Get.back();
                                    },
                                    child: const Text('아니요'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      controller.setUncorrectable(writingId: writing.writingId);
                                      Get.offAll(const MainFrame());
                                    },
                                    child: const Text('네'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Text(
                            '교정불가',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Container(
                        width: boxSize,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: HtmlEditor(
                          controller: htmlController,
                          htmlEditorOptions: HtmlEditorOptions(
                              initialText: writing.correction, hint: '문장을 교정하세요.'),
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
                              MyHtmlColor()
                                  .colorButton(controller: htmlController, color: MyStrings.red),
                              MyHtmlColor().colorButton(
                                  controller: htmlController, color: MyStrings.blue),
                              MyHtmlColor().colorButton(
                                  controller: htmlController, color: MyStrings.black),
                            ],
                          ),
                          callbacks: Callbacks(onChangeContent: (String? content) {
                            writing.correction = content;
                          }),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(30),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            completeCorrection();
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: Text(
                              '완료',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
