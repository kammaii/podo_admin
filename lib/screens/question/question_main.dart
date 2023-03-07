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
    Get.put(QuestionStateManager());

    return Scaffold(
      appBar: AppBar(
        title: const Text('질문'),
      ),
      body: GetX<QuestionStateManager>(
        builder: (controller) {
          String radioString = controller.searchRadio.value;
          Function(String?) radioFn = controller.changeSearchRadio();
          return Column(
            children: [
              Row(
                children: [
                  MyRadioBtn().getRadioButton(context: context, title: '신규', radio: radioString, f: radioFn),
                  MyRadioBtn().getRadioButton(context: context, title: '미선정', radio: radioString, f: radioFn),
                  MyRadioBtn().getRadioButton(context: context, title: '선정', radio: radioString, f: radioFn),
                  MyRadioBtn().getRadioButton(context: context, title: '게시중', radio: radioString, f: radioFn),
                  MyRadioBtn().getRadioButton(context: context, title: '전체', radio: radioString, f: radioFn),
                  const SizedBox(width: 30),
                  const SizedBox(height: 30, child: VerticalDivider()),
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        labelText: '내용 or 유저 검색',
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
                child: DataTable2(
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
                      DataCell(Text(MyDateFormat().getDateFormat(question.questionDate))),
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
                ),
              ),
            ],
          );
        }
      ),
    );
  }
}
