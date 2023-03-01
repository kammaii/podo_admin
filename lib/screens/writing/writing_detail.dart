import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:podo_admin/common/my_html_color.dart';
import 'package:podo_admin/screens/main_frame.dart';
import 'package:podo_admin/screens/value/my_strings.dart';
import 'package:podo_admin/screens/writing/writing.dart';
import 'package:podo_admin/screens/writing/writing_state_manager.dart';

class WritingDetail extends StatelessWidget {
  WritingDetail({Key? key}) : super(key: key);

  //final WritingStateManager _controller = Get.find<WritingStateManager>();
  final WritingStateManager _controller = Get.put(WritingStateManager()); //todo: Get.find로 바꾸기

  @override
  Widget build(BuildContext context) {
    //Message message = Get.arguments;
    Writing writing = Writing().getSampleWritings()[0];
    const double boxSize = 1000;
    HtmlEditorController htmlController = HtmlEditorController();

    return Scaffold(
      appBar: AppBar(title: const Text('교정 상세')),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(' 원본', textScaleFactor: 2),
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
            const Text(' 교정하기', textScaleFactor: 2),
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
                  htmlEditorOptions: HtmlEditorOptions(initialText: writing.correction, hint: '문장을 교정하세요.'),
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
                              writing.setCorrection(htmlController.getText().toString());
                              //todo: DB 저장
                              Get.offAll(const MainFrame());
                            },
                            child: const Text('네'),
                          ),
                        ],
                      ),
                    );
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
        ),
      ),
    );
  }
}
