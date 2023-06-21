import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/common/my_html_color.dart';
import 'package:podo_admin/screens/value/my_strings.dart';
import 'package:podo_admin/screens/writing/writing.dart';
import 'package:podo_admin/screens/writing/writing_state_manager.dart';

class WritingDetail extends StatelessWidget {
  WritingDetail({Key? key}) : super(key: key);

  late Writing writing;
  HtmlEditorController htmlController = HtmlEditorController();
  WritingStateManager controller = Get.find<WritingStateManager>();

  completeCorrection() {
    String title;
    if (writing.status == 1) {
      title = '교정을 수정하겠습니까?';
    } else if (writing.status == 3) {
      title = '교정완료 상태로 변경하겠습니까?';
    } else {
      title = '교정을 완료하겠습니까?';
    }
    Get.dialog(
      RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: (event) {
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.enter) {
              runSave();
            }
          }
        },
        child: AlertDialog(
          content: Text(title),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('아니요'),
            ),
            TextButton(
              onPressed: () {
                runSave();
              },
              child: const Text('네'),
            ),
          ],
        ),
      ),
    );
  }

  runSave() async {
    Get.back();
    Get.defaultDialog(title: '저장중', content: const Center(child: CircularProgressIndicator()));
    await Database()
        .updateCorrection(writingId: writing.id, correction: writing.correction, status: 1);
    controller.writings.removeAt(controller.writingIndex);
    controller.getWriting();
    Get.back();
    Get.snackbar('저장을 완료했습니다.', '');
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
              dispose: (_) {
                print('dISPOSE!');
              },
              builder: (controller) {
                writing = controller.writings[controller.writingIndex];
                htmlController.clear();
                (writing.correction.isEmpty)
                    ? htmlController.setText(writing.userWriting)
                    : htmlController.setText(writing.correction!);

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
                        Visibility(
                          visible: controller.statusRadio.value == '신규',
                          child: Text(
                            '(남은 교정 수 : ${controller.writings.length})',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(writing.questionTitle, textScaleFactor: 2),
                            const SizedBox(width: 20),
                            Text('( ${writing.id} )'),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                controller.getWriting(isNext: false);
                              },
                              icon: const Icon(Icons.arrow_circle_left_outlined),
                              iconSize: 30,
                              tooltip: '이전교정',
                            ),
                            IconButton(
                              onPressed: () {
                                controller.getWriting(isNext: true);
                              },
                              icon: const Icon(Icons.arrow_circle_right_outlined),
                              iconSize: 30,
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
                                content: const Text('Perfect로 체크하겠습니까?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Get.back();
                                    },
                                    child: const Text('아니요'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Database().updateCorrection(
                                          writingId: writing.id, status: 2);
                                      controller.writings.removeAt(controller.writingIndex);
                                      controller.getWriting();
                                      Get.back();
                                    },
                                    child: const Text('네'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Text(
                            'Perfect',
                            style: TextStyle(color: Colors.blueAccent),
                          ),
                        ),
                        Visibility(
                          visible: writing.status != 3,
                          child: TextButton(
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
                                        Database().updateCorrection(
                                            writingId: writing.id, status: 3);
                                        controller.writings.removeAt(controller.writingIndex);
                                        controller.getWriting();
                                        Get.back();
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
                            initialText:
                                (writing.correction.isEmpty) ? writing.userWriting : writing.correction,
                          ),
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
                              MyHtmlColor().colorButton(controller: htmlController, color: MyStrings.red),
                              MyHtmlColor().colorButton(controller: htmlController, color: MyStrings.blue),
                              MyHtmlColor().colorButton(controller: htmlController, color: MyStrings.black),
                            ],
                          ),
                          callbacks: Callbacks(onChangeContent: (String? content) {
                            writing.correction = content!;
                          }),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(30),
                      child: Center(
                        child: Visibility(
                          visible: writing.status != 2,
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
