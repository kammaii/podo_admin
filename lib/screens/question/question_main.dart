import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/my_date_format.dart';
import 'package:podo_admin/common/my_radio_btn.dart';
import 'package:podo_admin/screens/question/question.dart';
import 'package:podo_admin/screens/question/question_detail.dart';
import 'package:podo_admin/screens/question/question_state_manager.dart';

class QuestionMain extends StatelessWidget {
  QuestionMain({Key? key}) : super(key: key);

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    QuestionStateManager controller = Get.put(QuestionStateManager());

    return Scaffold(
      appBar: AppBar(
        title: const Text('질문'),
      ),
      body: GetX<QuestionStateManager>(
        builder: (controller) {
          String radioString = controller.searchRadio.value;
          Function(String?) radioFn = controller.changeSearchRadio();
          Widget getRadioBtn(String title) {
            return MyRadioBtn().getRadioButton(
              context: context,
              title: title,
              radio: radioString,
              f: radioFn,
            );
          }
          return Column(
            children: [
              Row(
                children: [
                  getRadioBtn('신규'),
                  getRadioBtn('미선정'),
                  getRadioBtn('선정'),
                  getRadioBtn('게시중'),
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
                  future: controller.futureQuestions,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if(snapshot.hasData == true) {
                      List<Question> questions = [];
                      for(dynamic snapshot in snapshot.data) {
                        questions.add(Question.fromJson(snapshot));
                      }
                      controller.questions = questions;
                      if(questions.isEmpty) {
                        return const Center(child: Text('검색된 질문이 없습니다.'));
                      } else {
                        return DataTable2(
                          columns: const [
                            DataColumn2(label: Text('날짜'), size: ColumnSize.S),
                            DataColumn2(label: Text('내용'), size: ColumnSize.L),
                            DataColumn2(label: Text('유저'), size: ColumnSize.S),
                            DataColumn2(label: Text('상태'), size: ColumnSize.S),
                          ],
                          rows: List<DataRow>.generate(controller.questions.length, (index) {
                            Question question = controller.questions[index];
                            String? status = controller.statusMap[question.status];

                            return DataRow(cells: [
                              DataCell(Text(MyDateFormat().getDateFormat(question.dateQuestion))),
                              DataCell(Text(question.question), onTap: () {
                                controller.questionIndex = index;
                                Get.to(QuestionDetail());
                              }),
                              DataCell(Text(question.userEmail), onTap: () {
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
