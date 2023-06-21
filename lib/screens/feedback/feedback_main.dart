import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/my_date_format.dart';
import 'package:podo_admin/common/my_radio_btn.dart';
import 'package:podo_admin/screens/feedback/feedback_detail.dart';
import 'package:podo_admin/screens/feedback/feedback_state_manager.dart';
import 'package:podo_admin/screens/feedback/feedback.dart' as fb;

class FeedbackMain extends StatelessWidget {
  FeedbackMain({Key? key}) : super(key: key);

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Get.put(FeedbackStateManager());

    return Scaffold(
      appBar: AppBar(
        title: const Text('피드백'),
      ),
      body: GetX<FeedbackStateManager>(
        builder: (controller) {
          String radioString = controller.searchRadio.value;
          Function(String?) radioFn = controller.changeSearchRadio();
          Widget getRadioBtn(String title) {
            return MyRadioBtn().getRadioButton(
              context: context,
              value: title,
              groupValue: radioString,
              f: radioFn,
            );
          }
          return Column(
            children: [
              Row(
                children: [
                  getRadioBtn('신규'),
                  getRadioBtn('검토중'),
                  getRadioBtn('검토완료'),
                  getRadioBtn('전체'),
                  const SizedBox(width: 30),
                  const SizedBox(height: 30, child: VerticalDivider()),
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        labelText: '내용 검색',
                      ),
                      onChanged: (text) {
                        //todo: 검색실행
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () {
                      _searchController.clear();
                    },
                    icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder(
                  future: controller.futureFeedbacks,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if(snapshot.hasData == true) {
                      List<fb.Feedback> feedbacks = [];
                      for(dynamic snapshot in snapshot.data) {
                        feedbacks.add(fb.Feedback.fromJson(snapshot));
                      }
                      controller.feedbacks = feedbacks;
                      if(feedbacks.isEmpty) {
                        return const Center(child: Text('검색된 피드백이 없습니다.'));
                      } else {
                        return DataTable2(
                          columns: const [
                            DataColumn2(label: Text('날짜'), size: ColumnSize.S),
                            DataColumn2(label: Text('내용'), size: ColumnSize.L),
                            DataColumn2(label: Text('유저이메일'), size: ColumnSize.S),
                            DataColumn2(label: Text('상태'), size: ColumnSize.S),
                          ],
                          rows: List<DataRow>.generate(controller.feedbacks.length, (index) {
                            fb.Feedback feedback = controller.feedbacks[index];
                            String? status = controller.statusMap[feedback.status];

                            return DataRow(cells: [
                              DataCell(Text(MyDateFormat().getDateFormat(feedback.date))),
                              DataCell(Text(feedback.message), onTap: () {
                                controller.feedbackIndex = index;
                                Get.to(FeedbackDetail());
                              }),
                              DataCell(Text(feedback.userEmail), onTap: () {
                                //todo: '유저로검색'
                              }, onDoubleTap: () {
                                //todo: '유저정보열기'
                              }),
                              DataCell(Text(status!)),
                            ]);
                          }),
                        );
                      }
                    } else if (snapshot.hasError) {
                      return Text('에러: ${snapshot.error}');
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            ],
          );
        }
      ),
    );
  }
}
