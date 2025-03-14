import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/common/my_date_format.dart';
import 'package:podo_admin/common/my_radio_btn.dart';
import 'package:podo_admin/common/my_textfield.dart';
import 'package:podo_admin/screens/feedback/feedback_state_manager.dart';
import 'package:podo_admin/screens/feedback/trans_feedback.dart';
import 'package:podo_admin/screens/lesson/lesson_card.dart';
import 'package:podo_admin/screens/user/user_main.dart';
import 'package:responsive_framework/responsive_framework.dart';

class FeedbackMain extends StatelessWidget {
  FeedbackMain({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FeedbackStateManager controller = Get.put(FeedbackStateManager());

    Widget getRadioBtn(String title) {
      return MyRadioBtn().getRadioButton(
        context: context,
        value: title,
        groupValue: controller.statusRadio,
        f: controller.changeStatusRadio(),
      );
    }

    void saveFeedback(TransFeedback fb, String feedback) {
      print(feedback);
      Get.dialog(AlertDialog(
        title: const Text('저장할까요?'),
        actions: [
          ElevatedButton(
              onPressed: () async {
                Get.back();
                Get.back();
                await Database().updateField(
                    collection: 'Lessons/${fb.lessonId}/LessonCards',
                    docId: fb.cardId,
                    map: {'content.${fb.language}': feedback});
                await Database().updateField(collection: 'TransFeedbacks', docId: fb.id, map: {'isChecked': true});
              },
              child: const Text('네')),
          ElevatedButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('아니요')),
        ],
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('피드백'),
        automaticallyImplyLeading: false,
      ),
      body: GetBuilder<FeedbackStateManager>(
        builder: (controller) {
          return Column(
            children: [
              Row(
                children: [
                  getRadioBtn('신규'),
                  getRadioBtn('확인'),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder(
                  future: controller.futureFeedbacks,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData == true) {
                      List<TransFeedback> feedbacks = [];
                      for (dynamic snapshot in snapshot.data) {
                        feedbacks.add(TransFeedback.fromJson(snapshot));
                      }
                      controller.feedbacks = feedbacks;
                      if (feedbacks.isEmpty) {
                        return const Center(child: Text('검색된 피드백이 없습니다.'));
                      } else {
                        if (ResponsiveBreakpoints.of(context).largerThan(TABLET)) {
                          return DataTable2(
                            columns: const [
                              DataColumn2(label: Text('날짜'), size: ColumnSize.S),
                              DataColumn2(label: Text('유저아이디'), size: ColumnSize.S),
                              DataColumn2(label: Text('이름'), size: ColumnSize.S),
                              DataColumn2(label: Text('레슨타이틀'), size: ColumnSize.L),
                              DataColumn2(label: Text('피드백'), size: ColumnSize.S),
                              DataColumn2(label: Text('언어'), size: ColumnSize.S),
                              DataColumn2(label: Text('상태'), size: ColumnSize.S),
                              DataColumn2(label: Text('삭제'), size: ColumnSize.S),
                            ],
                            rows: List<DataRow>.generate(controller.feedbacks.length, (index) {
                              TransFeedback feedback = controller.feedbacks[index];

                              return DataRow(cells: [
                                DataCell(Text(MyDateFormat().getDateFormat(feedback.date))),
                                DataCell(Text(feedback.userId.substring(0, 8)), onDoubleTap: () {
                                  Get.to(UserMain(userId: feedback.userId));
                                }),
                                DataCell(Text(feedback.userName)),
                                DataCell(Text(feedback.lessonTitle)),
                                DataCell(Text(feedback.feedback), onTap: () async {
                                  DocumentSnapshot<Map<String, dynamic>> snapshot = await Database().getDoc(
                                      collection: 'Lessons/${feedback.lessonId}/LessonCards',
                                      doc: feedback.cardId);
                                  LessonCard card = LessonCard.fromJson(snapshot.data() as Map<String, dynamic>);
                                  String fixedContent = '';
                                  Get.dialog(AlertDialog(
                                    content: SizedBox(
                                      width: 600,
                                      child: Column(
                                        children: [
                                          const Text('피드백'),
                                          const SizedBox(height: 20),
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.all(20),
                                              decoration: BoxDecoration(
                                                  border: Border.all(), borderRadius: BorderRadius.circular(20)),
                                              child: MyTextField().getTextField(
                                                  controller: TextEditingController(text: feedback.feedback)),
                                            ),
                                          ),
                                          const SizedBox(height: 30),
                                          const Text('원본'),
                                          const SizedBox(height: 20),
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.all(20),
                                              decoration: BoxDecoration(
                                                  border: Border.all(), borderRadius: BorderRadius.circular(20)),
                                              child: MyTextField().getTextField(
                                                  controller:
                                                      TextEditingController(text: card.content[feedback.language]),
                                                  fn: (value) {
                                                    fixedContent = value;
                                                  }),
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              ElevatedButton(
                                                  onPressed: () {
                                                    fixedContent = feedback.feedback;
                                                    saveFeedback(feedback, fixedContent);
                                                  },
                                                  child: const Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                    child: Text('피드백 반영'),
                                                  )),
                                              const SizedBox(width: 50),
                                              ElevatedButton(
                                                  onPressed: () {
                                                    saveFeedback(feedback, fixedContent);
                                                  },
                                                  child: const Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                    child: Text('수동 저장'),
                                                  )),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          const Text('explain 카드는 수동으로 수정할 것', style: TextStyle(color: Colors.red))
                                        ],
                                      ),
                                    ),
                                  ));
                                }),
                                DataCell(Text(feedback.language)),
                                DataCell(
                                    Icon(Icons.circle, color: feedback.isChecked ? Colors.green : Colors.red)),
                                DataCell(
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      Get.dialog(AlertDialog(
                                        title: const Text('정말 삭제하겠습니까?'),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Get.back();
                                                Database().deleteDoc(collection: 'TransFeedbacks', doc: feedback);
                                              },
                                              child: const Text(
                                                '네',
                                                style: TextStyle(color: Colors.red),
                                              )),
                                          TextButton(
                                              onPressed: () {
                                                Get.back();
                                              },
                                              child: const Text('아니오')),
                                        ],
                                      ));
                                    },
                                  ),
                                ),
                              ]);
                            }),
                          );
                        } else {
                          return DataTable2(
                            columns: const [
                              DataColumn2(label: Text('날짜'), size: ColumnSize.L),
                              DataColumn2(label: Text('이름'), size: ColumnSize.L),
                              DataColumn2(label: Text('레슨타이틀'), size: ColumnSize.L),
                              DataColumn2(label: Text('언어'), size: ColumnSize.S),
                              DataColumn2(label: Text('삭제'), size: ColumnSize.S),
                            ],
                            rows: List<DataRow>.generate(controller.feedbacks.length, (index) {
                              TransFeedback feedback = controller.feedbacks[index];

                              return DataRow(cells: [
                                DataCell(Text(MyDateFormat().getDateOnlyFormat(feedback.date))),
                                DataCell(Text(feedback.userName), onDoubleTap: () {
                                  Get.to(UserMain(userId: feedback.userId));
                                }),
                                DataCell(Text(feedback.lessonTitle), onTap: () async {
                                  DocumentSnapshot<Map<String, dynamic>> snapshot = await Database().getDoc(
                                      collection: 'Lessons/${feedback.lessonId}/LessonCards',
                                      doc: feedback.cardId);
                                  LessonCard card = LessonCard.fromJson(snapshot.data() as Map<String, dynamic>);
                                  String fixedContent = '';
                                  Get.dialog(AlertDialog(
                                    content: SizedBox(
                                      width: 600,
                                      child: Column(
                                        children: [
                                          const Text('피드백'),
                                          const SizedBox(height: 20),
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.all(20),
                                              decoration: BoxDecoration(
                                                  border: Border.all(), borderRadius: BorderRadius.circular(20)),
                                              child: MyTextField().getTextField(
                                                  controller: TextEditingController(text: feedback.feedback)),
                                            ),
                                          ),
                                          const SizedBox(height: 30),
                                          const Text('원본'),
                                          const SizedBox(height: 20),
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.all(20),
                                              decoration: BoxDecoration(
                                                  border: Border.all(), borderRadius: BorderRadius.circular(20)),
                                              child: MyTextField().getTextField(
                                                  controller:
                                                  TextEditingController(text: card.content[feedback.language]),
                                                  fn: (value) {
                                                    fixedContent = value;
                                                  }),
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              ElevatedButton(
                                                  onPressed: () {
                                                    fixedContent = feedback.feedback;
                                                    saveFeedback(feedback, fixedContent);
                                                  },
                                                  child: const Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                    child: Text('피드백 반영'),
                                                  )),
                                              const SizedBox(width: 50),
                                              ElevatedButton(
                                                  onPressed: () {
                                                    saveFeedback(feedback, fixedContent);
                                                  },
                                                  child: const Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                    child: Text('수동 저장'),
                                                  )),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          const Text('explain 카드는 수동으로 수정할 것', style: TextStyle(color: Colors.red))
                                        ],
                                      ),
                                    ),
                                  ));
                                }),
                                DataCell(Text(feedback.language)),
                                DataCell(
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      Get.dialog(AlertDialog(
                                        title: const Text('정말 삭제하겠습니까?'),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Get.back();
                                                Database().deleteDoc(collection: 'TransFeedbacks', doc: feedback);
                                              },
                                              child: const Text(
                                                '네',
                                                style: TextStyle(color: Colors.red),
                                              )),
                                          TextButton(
                                              onPressed: () {
                                                Get.back();
                                              },
                                              child: const Text('아니오')),
                                        ],
                                      ));
                                    },
                                  ),
                                ),
                              ]);
                            }),
                          );
                        }
                      }
                    } else if (snapshot.hasError) {
                      return Text('에러: ${snapshot.error}');
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
