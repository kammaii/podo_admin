import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/common/my_radio_btn.dart';
import 'package:podo_admin/screens/podo_message/podo_message_state_manager.dart';
import 'package:podo_admin/screens/podo_message/podo_message_reply.dart';

class CloudMessageReplyMain extends StatefulWidget {
  CloudMessageReplyMain({Key? key}) : super(key: key);

  @override
  State<CloudMessageReplyMain> createState() => _CloudMessageReplyMainState();
}

class _CloudMessageReplyMainState extends State<CloudMessageReplyMain> {
  PodoMessageStateManager controller = Get.find<PodoMessageStateManager>();

  @override
  void dispose() {
    super.dispose();
    controller.initRadio();
  }

  @override
  Widget build(BuildContext context) {
    List<bool> selector = [true, false];
    const List<Widget> selectorWidget = [
      SizedBox(width: 60, child: Center(child: Text('미선정'))),
      SizedBox(width: 60, child: Center(child: Text('선정')))
    ];
    controller.getReplies(isSelected: false);

    Widget getRadioBtn(String title) {
      return MyRadioBtn().getRadioButton(
        context: context,
        value: title,
        groupValue: controller.statusRadio.value,
        f: controller.changeStatusRadio(),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('포도 메시지 선정   ( ${Get.arguments} )'),
        ),
        body: Column(
          children: [
            Obx(
              () => Row(
                children: [
                  getRadioBtn('미선정'),
                  getRadioBtn('선정'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GetBuilder<PodoMessageStateManager>(
                builder: (_) {
                  if (controller.replies.isNotEmpty) {
                    return DataTable2(
                      columns: const [
                        DataColumn2(label: Text('순서'), size: ColumnSize.S),
                        DataColumn2(label: Text('내용'), size: ColumnSize.L),
                        DataColumn2(label: Text('유저이름'), size: ColumnSize.S),
                        DataColumn2(label: Text('상태'), size: ColumnSize.S),
                      ],
                      rows: List<DataRow>.generate(controller.replies.length, (index) {
                        PodoMessageReply reply = controller.replies[index];
                        reply.isSelected ? selector = [false, true] : selector = [true, false];

                        return DataRow(cells: [
                          DataCell(Text((controller.replies.length - index).toString())),
                          DataCell(Text(reply.reply), onTap: () {
                            Get.dialog(AlertDialog(
                              content: Text(reply.reply),
                            ));
                          }),
                          DataCell(Text(reply.userName)),
                          DataCell(
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: ToggleButtons(
                                  onPressed: (int toggleIndex) {
                                    toggleIndex == 0 ? selector = [true, false] : selector = [false, true];
                                    controller.setReplySelection(replyId: reply.id, selection: selector[1]);
                                    controller.replies[index].isSelected = selector[1];
                                    controller.update();
                                  },
                                  isSelected: selector,
                                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                                  children: selectorWidget),
                            ),
                          ),
                        ]);
                      }),
                    );
                  } else {
                    return const Center(child: Text('검색된 회신이 없습니다.'));
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30),
              child: ElevatedButton(
                onPressed: () {
                  Get.dialog(AlertDialog(
                    title: const Text('Best Reply를 확정 하겠습니까?'),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Get.back();
                          },
                          child: const Text('아니요')),
                      TextButton(
                          onPressed: () {
                            controller.setBestReply();
                            Get.back();
                            Get.back();
                          },
                          child: const Text('네')),
                    ],
                  ));
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    '선정 완료',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
