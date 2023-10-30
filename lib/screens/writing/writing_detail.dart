import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/common/my_html_color.dart';
import 'package:podo_admin/screens/value/my_strings.dart';
import 'package:podo_admin/screens/writing/writing.dart';
import 'package:podo_admin/screens/writing/writing_state_manager.dart';

class WritingDetail extends StatefulWidget {
  WritingDetail({Key? key}) : super(key: key);

  @override
  State<WritingDetail> createState() => _WritingDetailState();
}

class _WritingDetailState extends State<WritingDetail> {
  late Writing writing;
  HtmlEditorController htmlController = HtmlEditorController();
  WritingStateManager controller = Get.find<WritingStateManager>();
  late List<bool> isCorrectedList;
  String initialContent = '';

  completeCorrection() {
    Get.dialog(
      controller.allCorrection.value
          ? AlertDialog(
              content: checkIsCorrectedAll() ? const Text('교정을 완료하겠습니까?') : const Text('모든 교정이 완료되지 않았습니다.'),
              actions: checkIsCorrectedAll()
                  ? [
                      TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: const Text('아니요'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Get.back();
                          Get.defaultDialog(
                              title: '저장중', content: const Center(child: CircularProgressIndicator()));
                          for (Writing w in controller.writings) {
                            await runSave(w);
                          }
                          Get.back();
                          Get.back();
                          Get.snackbar('저장을 완료했습니다.', '', snackPosition: SnackPosition.BOTTOM);
                        },
                        child: const Text('네'),
                      ),
                    ]
                  : [],
            )
          : AlertDialog(
              content: const Text('교정을 완료하겠습니까?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text('아니요'),
                ),
                TextButton(
                  onPressed: () async {
                    Get.back();
                    Get.defaultDialog(title: '저장중', content: const Center(child: CircularProgressIndicator()));
                    await runSave(writing);
                    if(controller.writings.length > 1) {
                      controller.writings.removeAt(controller.writingIndex);
                      controller.getWriting();
                    } else {
                      Get.back();
                    }
                    Get.back();
                    Get.snackbar('저장을 완료했습니다.', '', snackPosition: SnackPosition.BOTTOM);
                  },
                  child: const Text('네'),
                ),
              ],
            ),
    );
  }

  Future<void> runSave(Writing wt) {
    if (wt.status == 0) {
      wt.status = 1;
    }
    return Database().updateCorrection(writingId: wt.id, correction: wt.correction, status: wt.status);
  }

  Widget getCircle(Color color) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  bool checkIsCorrectedAll() {
    for (bool b in isCorrectedList) {
      if (!b) {
        return false;
      }
    }
    return true;
  }


  @override
  void initState() {
    super.initState();
    isCorrectedList = List<bool>.filled(controller.writings.length, false);
  }

  @override
  Widget build(BuildContext context) {
    const double boxSize = 1000;
    writing = controller.writings[controller.writingIndex];
    htmlController.clear();
    (writing.correction.isEmpty)
        ? htmlController.setText(writing.userWriting)
        : htmlController.setText(writing.correction);
    return Scaffold(
      appBar: AppBar(title: const Text('교정_상세')),
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: (event) {
          if (event is RawKeyDownEvent) {
            setState(() {
              if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                controller.getWriting(isNext: false);
              } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                controller.getWriting(isNext: true);
              }
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SizedBox(
            width: boxSize,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    getCircle(controller.statusColor[writing.status]!),
                    const SizedBox(width: 10),
                    Text(controller.statusMap[writing.status]!, textScaleFactor: 2),
                    const SizedBox(width: 20),
                    Text(
                      '(순서: ${controller.writingIndex + 1} / ${controller.writings.length})',
                      style: const TextStyle(color: Colors.red),
                    ),
                    Visibility(
                      visible: controller.statusRadio == '신규',
                      child: Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(checkIsCorrectedAll() ? '검토완료' : '검토중',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 10),
                            checkIsCorrectedAll() ? getCircle(Colors.green) : getCircle(Colors.red),
                          ],
                        ),
                      ),
                    )
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
                            setState(() {
                              controller.getWriting(isNext: false);
                            });
                          },
                          icon: const Icon(Icons.arrow_circle_left_outlined),
                          iconSize: 30,
                          tooltip: '이전교정',
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              controller.getWriting(isNext: true);
                            });
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
                        setState(() {
                          writing.correction = MyStrings.perfect;
                          writing.status = 2;
                        });
                      },
                      child: const Text(
                        'Perfect',
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          writing.correction = MyStrings.noKorean;
                          writing.status = 3;
                        });
                      },
                      child: const Text(
                        '한국어 아님',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          writing.correction = MyStrings.noTopic;
                          writing.status = 3;
                        });
                      },
                      child: const Text(
                        '주제에 맞지 않는 글',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          writing.correction = MyStrings.cantUnderstand;
                          writing.status = 3;
                        });
                      },
                      child: const Text(
                        '이해불가',
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
                        initialText: (writing.correction.isEmpty) ? writing.userWriting : writing.correction,
                      ),
                      htmlToolbarOptions: HtmlToolbarOptions(
                        defaultToolbarButtons: [
                          const OtherButtons(
                              fullscreen: false, undo: false, redo: false, copy: false, paste: false, help: false),
                        ],
                        customToolbarButtons: [
                          MyHtmlColor().colorButton(controller: htmlController, color: MyStrings.red),
                          MyHtmlColor().colorButton(controller: htmlController, color: MyStrings.blue),
                          MyHtmlColor().colorButton(controller: htmlController, color: MyStrings.black),
                        ],
                      ),
                      callbacks: Callbacks(onChangeContent: (String? content) {
                        if(content != '<p><br></p>' && writing.userWriting != content && writing.correction == content) {
                          isCorrectedList[controller.writingIndex] = true;
                        }
                        writing.correction = content!;
                      }),
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
                      const SizedBox(width: 20),
                      Obx(() {
                        return Checkbox(
                            value: controller.allCorrection.value,
                            onChanged: (bool? b) {
                              controller.allCorrection.value = b!;
                            });
                      }),
                      const Text('전체 교정')
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
