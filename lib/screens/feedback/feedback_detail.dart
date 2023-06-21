import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:podo_admin/common/my_radio_btn.dart';
import 'package:podo_admin/screens/feedback/feedback.dart' as fb;
import 'package:podo_admin/screens/feedback/feedback_state_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackDetail extends StatelessWidget {
  FeedbackDetail({Key? key}) : super(key: key);

  late fb.Feedback feedback;
  final double boxSize = 1000;
  final HtmlEditorController htmlController = HtmlEditorController();
  String reply = '';


  @override
  Widget build(BuildContext context) {
    Get.find<FeedbackStateManager>();

    return Scaffold(
      appBar: AppBar(title: const Text('피드백_상세')),
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: (event) {
          FeedbackStateManager controller = Get.find<FeedbackStateManager>();
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              controller.changeFeedbackIndex(isNext: false);
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              controller.changeFeedbackIndex(isNext: true);
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: GetBuilder<FeedbackStateManager>(
            builder: (controller) {
              feedback = controller.feedbacks[controller.feedbackIndex];
              controller.setFeedbackOptions();
              htmlController.clear();

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
                          color: controller.statusColor[feedback.status],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(controller.statusMap[feedback.status]!, textScaleFactor: 2),
                      const SizedBox(width: 20),
                      Text(
                        '(${controller.feedbacks.indexOf(feedback) + 1} / ${controller.feedbacks.length})',
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(width: 20),
                      Text('유저이메일: ${feedback.userEmail}'),
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
                                      Row(
                                        children: [
                                          getRadioBtn('신규'),
                                          getRadioBtn('검토중'),
                                          getRadioBtn('검토완료'),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          controller.changeFeedbackIndex(isNext: false);
                                        },
                                        icon: const Icon(Icons.arrow_circle_left_outlined),
                                        iconSize: 30,
                                        tooltip: '이전피드백',
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          controller.changeFeedbackIndex(isNext: true);
                                        },
                                        icon: const Icon(Icons.arrow_circle_right_outlined),
                                        iconSize: 30,
                                        tooltip: '다음피드백',
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
                                  child: Text(feedback.message),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text('회신', textScaleFactor: 2),
                              Expanded(
                                child: Container(
                                  width: boxSize,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    border: Border.all(),
                                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                                  ),
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (value) {
                                      reply = value.toString();
                                    },
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(30),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    //todo: 이메일로 회신하기
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    child: Text(
                                      '회신',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ),
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
