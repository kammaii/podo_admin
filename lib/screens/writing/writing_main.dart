import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/my_date_format.dart';
import 'package:podo_admin/common/my_radio_btn.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:podo_admin/screens/writing/writing.dart';
import 'package:podo_admin/screens/writing/writing_detail.dart';
import 'package:podo_admin/screens/writing/writing_state_manager.dart';

class WritingMain extends StatelessWidget {
  WritingMain({Key? key}) : super(key: key);

  final WritingStateManager _controller = Get.put(WritingStateManager());
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('교정'),
      ),
      body: GetBuilder<WritingStateManager>(
        builder: (controller) {
          return Column(
            children: [
              Row(
                children: [
                  MyRadioBtn().getRadioButton(context: context, title: '신규', radio: _controller.tagRadio, f: _controller.changeTagRadio()),
                  MyRadioBtn().getRadioButton(context: context, title: '완료', radio: _controller.tagRadio, f: _controller.changeTagRadio()),
                  MyRadioBtn().getRadioButton(context: context, title: '전체', radio: _controller.tagRadio, f: _controller.changeTagRadio()),
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
                  rows: List<DataRow>.generate(_controller.writings.length, (index) {
                    Writing writing = _controller.writings[index];

                    return DataRow(cells: [
                      DataCell(Text(MyDateFormat().getDateFormat(writing.writingDate))),
                      DataCell(Text(writing.userWriting), onTap: () {
                        Get.to(WritingDetail(), arguments: writing);
                      }),
                      DataCell(Text(writing.userEmail), onTap: () {
                        //todo: '유저로검색'
                      }, onDoubleTap: () {
                        //todo: '유저정보열기'
                      }),
                      DataCell(Text(writing.status.toString())),
                    ]);
                  }),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
