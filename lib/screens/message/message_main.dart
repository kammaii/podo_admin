import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/my_date_format.dart';
import 'package:podo_admin/common/my_radio_btn.dart';
import 'package:podo_admin/screens/message/message.dart';
import 'package:podo_admin/screens/message/message_detail.dart';
import 'package:podo_admin/screens/message/message_state_manager.dart';
import 'package:data_table_2/data_table_2.dart';

class MessageMain extends StatelessWidget {
  MessageMain({Key? key}) : super(key: key);

  final MessageStateManager _controller = Get.put(MessageStateManager());
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('메시지'),
      ),
      body: GetBuilder<MessageStateManager>(
        builder: (controller) {
          return Column(
            children: [
              Row(
                children: [
                  MyRadioBtn().getRadioButton(context: context, title: '전체', radio: _controller.tagRadio, f: _controller.changeTagRadio()),
                  MyRadioBtn().getRadioButton(context: context, title: '교정', radio: _controller.tagRadio, f: _controller.changeTagRadio()),
                  MyRadioBtn().getRadioButton(context: context, title: '질문', radio: _controller.tagRadio, f: _controller.changeTagRadio()),
                  const SizedBox(height: 30, child: VerticalDivider()),
                  MyRadioBtn().getRadioButton(context: context, title: '신규', radio: _controller.statusRadio, f: _controller.changeStatusRadio()),
                  MyRadioBtn().getRadioButton(context: context, title: '완료', radio: _controller.statusRadio, f: _controller.changeStatusRadio()),
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
                    DataColumn2(label: Text('태그'), size: ColumnSize.S),
                    DataColumn2(label: Text('내용'), size: ColumnSize.L),
                    DataColumn2(label: Text('유저'), size: ColumnSize.S),
                    DataColumn2(label: Text('상태'), size: ColumnSize.S),
                  ],
                  rows: List<DataRow>.generate(_controller.messages.length, (index) {
                    Message message = _controller.messages[index];

                    return DataRow(cells: [
                      DataCell(Text(MyDateFormat().getDateFormat(message.sendTime))),
                      DataCell(Text(message.tag)),
                      DataCell(Text(message.message), onTap: () {
                        Get.to(MessageDetail(), arguments: message);
                      }),
                      DataCell(Text(message.userEmail), onTap: () {
                        //todo: '유저로검색'
                      }, onDoubleTap: () {
                        //todo: '유저정보열기'
                      }),
                      DataCell(Text(message.status)),
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
