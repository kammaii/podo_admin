import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:podo_admin/common/my_html_color.dart';
import 'package:podo_admin/screens/main_frame.dart';
import 'package:podo_admin/screens/message/message.dart';
import 'package:podo_admin/screens/message/message_finder.dart';
import 'package:podo_admin/screens/message/message_state_manager.dart';
import 'package:podo_admin/screens/value/my_strings.dart';

class MessageDetail extends StatelessWidget {
  MessageDetail({Key? key}) : super(key: key);

  //final MessageStateManager _controller = Get.find<MessageStateManager>();
  final MessageStateManager _controller = Get.put(MessageStateManager()); //todo: Get.find로 바꾸기

  @override
  Widget build(BuildContext context) {
    //Message message = Get.arguments;
    Message message = Message().getSampleMessages()[0];
    _controller.isFavoriteMessage = message.isFavorite;
    String tag = '';
    const double boxSize = 1000;
    final Color starColor = Theme.of(context).colorScheme.primary;
    const double starSize = 35;

    if (message.tag == MyStrings.correction) {
      tag = ' 교정';
    } else if (message.tag == MyStrings.question) {
      tag = ' 질문';
    }
    HtmlEditorController htmlController = HtmlEditorController();

    return Scaffold(
      appBar: AppBar(title: const Text('메시지 상세')),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(tag, textScaleFactor: 2),
                const SizedBox(width: 20),
                GetBuilder<MessageStateManager>(
                  builder: (controller) {
                    return IconButton(
                      onPressed: () {
                        _controller.isFavoriteMessage = !_controller.isFavoriteMessage;
                        _controller.update();
                      },
                      icon: _controller.isFavoriteMessage
                          ? Icon(Icons.star, color: starColor, size: starSize)
                          : Icon(Icons.star_border_outlined, color: starColor, size: starSize),
                    );
                  },
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
                child: Text(message.message),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text(' 답변', textScaleFactor: 2),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    Get.to(MessageFinder());
                  },
                  child: const Text('답변찾기'),
                )
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
                  htmlEditorOptions: HtmlEditorOptions(initialText: message.reply, hint: '답변을 입력하세요.'),
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
                    message.reply = content;
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
                        content: const Text('답변을 보내겠습니까?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Get.back();
                            },
                            child: const Text('취소'),
                          ),
                          TextButton(
                            onPressed: () {
                              message.setReply(htmlController.getText().toString());
                              //todo: DB 저장
                              Get.offAll(const MainFrame());
                            },
                            child: const Text('보내기'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      '보내기',
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
