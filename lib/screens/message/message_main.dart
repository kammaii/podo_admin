import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/screens/message/message.dart';
import 'package:podo_admin/screens/message/message_state_manager.dart';
import 'package:podo_admin/screens/value/my_strings.dart';
import 'package:data_table_2/data_table_2.dart';

class MessageMain extends StatelessWidget {
  MessageMain({Key? key}) : super(key: key);

  final MessageStateManager _controller = Get.put(MessageStateManager());
  final TextEditingController _searchController = TextEditingController();

  Widget getRadioButton(BuildContext context, bool isTag, String title) {
    return SizedBox(
      width: 150,
      child: ListTile(
        title: Text(title),
        leading: Radio(
          value: title,
          activeColor: Theme.of(context).colorScheme.primary,
          groupValue: isTag ? _controller.tagRadio : _controller.statusRadio,
          onChanged: (String? newValue) {
            isTag ? _controller.tagRadio = newValue! : _controller.statusRadio = newValue!;
            _controller.update();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(MyStrings.message),
      ),
      body: GetBuilder<MessageStateManager>(
        builder: (controller) {
          return Column(
            children: [
              Row(
                children: [
                  getRadioButton(context, true, '전체'),
                  getRadioButton(context, true, '교정'),
                  getRadioButton(context, true, '질문'),
                  const SizedBox(height: 30, child: VerticalDivider()),
                  getRadioButton(context, false, '신규'),
                  getRadioButton(context, false, '완료'),
                  const SizedBox(height: 30, child: VerticalDivider()),
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        labelText: '검색',
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
                      DataCell(Text(message.sendTime.toString())),
                      DataCell(Text(message.tag)),
                      DataCell(Text(message.message), onTap: () {
                        print('상세보기');
                      }),
                      DataCell(Text(message.userEmail), onTap: () {
                        print('유저로검색');
                      }, onDoubleTap: () {
                        print('유저정보열기');
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
