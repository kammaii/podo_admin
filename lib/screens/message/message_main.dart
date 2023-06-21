import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:podo_admin/common/my_date_format.dart';
import 'package:podo_admin/common/my_html_color.dart';
import 'package:podo_admin/common/my_radio_btn.dart';
import 'package:podo_admin/screens/message/message.dart';
import 'package:podo_admin/screens/message/message_state_manager.dart';
import 'package:podo_admin/screens/value/my_strings.dart';

class MessageMain extends StatelessWidget {
  MessageMain({Key? key}) : super(key: key);
  final MessageStateManager _controller = Get.put(MessageStateManager());
  late final TextEditingController _textEditingController = TextEditingController();
  late final HtmlEditorController _htmlEditorController = HtmlEditorController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add_circle_outline_rounded),
        label: const Text('알림만들기'),
      ),
      appBar: AppBar(
        title: const Text('알림'),
      ),
      body: GetBuilder<MessageStateManager>(
        builder: (controller) {
          return DataTable2(
            columns: const [
              DataColumn2(label: Text('No'), size: ColumnSize.S),
              DataColumn2(label: Text('태그'), size: ColumnSize.S),
              DataColumn2(label: Text('타이틀'), size: ColumnSize.L),
              DataColumn2(label: Text('만료일'), size: ColumnSize.M),
              DataColumn2(label: Text('활성화'), size: ColumnSize.S),
              DataColumn2(label: Text('삭제'), size: ColumnSize.S),
              DataColumn2(label: Text(''), size: ColumnSize.S),
            ],
            rows: List<DataRow>.generate(controller.notices.length, (index) {
              Message notice = controller.notices[index];

              return DataRow(cells: [
                DataCell(Text(index.toString())),
                DataCell(Text(notice.tag)),
                DataCell(Text(notice.title)),
                notice.deadLine != null
                    ? DataCell(Text(MyDateFormat().getDateFormat(notice.deadLine!)))
                    : const DataCell(Text('-')),
                DataCell(Checkbox(
                  value: notice.isActive,
                  onChanged: (bool? value) {
                    String title = value! ? '알림 활성화' : '알림 비활성화';
                    String content = value! ? '이 알림을 활성화 하겠습니까?' : '이 알림을 비활성화 하겠습니까?';
                    getDialog(
                      context: context,
                      title: title,
                      content: content,
                      functionNo: () {
                        Get.back();
                      },
                      functionYes: () {
                        controller.setNoticeActive(index, value);
                        Get.back();
                      },
                    );
                  },
                )),
                DataCell(IconButton(
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                  onPressed: () {
                    getDialog(
                      context: context,
                      title: '알림삭제',
                      content: '이 알림을 삭제하겠습니까?',
                      functionNo: () {
                        Get.back();
                      },
                      functionYes: () {
                        controller.deleteNotice(index);
                        Get.back();
                      },
                    );
                  },
                )),
                DataCell(ElevatedButton(
                  child: const Text('상세보기'),
                  onPressed: () {
                    getNoticeDialog(context: context, notice: notice, title: '알림 상세보기');
                  },
                ))
              ]);
            }),
          );
        },
      ),
    );
  }

  Widget getNoticeLine({required String item, required Widget contents}) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(item),
        ),
        contents,
      ],
    );
  }

  void getNoticeDialog({
    required BuildContext context,
    required Message notice,
    required String title,
  }) {
    notice.deadLine == null ? _controller.hasDeadLine = false : _controller.hasDeadLine = true;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: GetBuilder<MessageStateManager>(
            builder: (controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  getNoticeLine(item: '아이디', contents: Text(notice.noticeId)),
                  const SizedBox(height: 10),
                  getNoticeLine(
                    item: '태그',
                    contents: Row(
                      children: [
                        MyRadioBtn().getRadioButton(
                            context: context,
                            value: MyStrings.tagInfo,
                            groupValue: _controller.noticeTag,
                            f: _controller.changeTagRadio()),
                        MyRadioBtn().getRadioButton(
                            context: context,
                            value: MyStrings.tagQuiz,
                            groupValue: _controller.noticeTag,
                            f: _controller.changeTagRadio()),
                        MyRadioBtn().getRadioButton(
                            context: context,
                            value: MyStrings.tagLiveLesson,
                            groupValue: _controller.noticeTag,
                            width: 200,
                            f: _controller.changeTagRadio()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  getNoticeLine(
                    item: '타이틀',
                    contents: SizedBox(
                      width: 500,
                      child: TextField(
                        controller: _textEditingController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  getNoticeLine(
                      item: '만료일',
                      contents: Row(
                        children: [
                          Checkbox(
                            value: _controller.hasDeadLine,
                            onChanged: (bool? value) {
                              _controller.hasDeadLine = value!;
                              if (value) {
                                notice.deadLine = DateTime.now();
                              } else {
                                notice.deadLine = null;
                              }
                              _controller.update();
                            },
                            activeColor: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          _controller.hasDeadLine
                              ? Text(MyDateFormat().getDateOnlyFormat(notice.deadLine!))
                              : const Text('없음'),
                          const SizedBox(width: 10),
                          _controller.hasDeadLine
                              ? ElevatedButton(
                                  onPressed: () {
                                    selectDate(context, notice);
                                  },
                                  child: const Text('날짜설정'))
                              : const SizedBox.shrink(),
                        ],
                      )),
                  const SizedBox(height: 10),
                  Expanded(
                    child: getNoticeLine(
                      item: '내용',
                      contents: Container(
                        width: 500,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: HtmlEditor(
                          controller: _htmlEditorController,
                          htmlEditorOptions: HtmlEditorOptions(initialText: notice.contents),
                          htmlToolbarOptions: HtmlToolbarOptions(
                            toolbarType: ToolbarType.nativeGrid,
                            defaultToolbarButtons: [
                              const StyleButtons(),
                              const ListButtons(listStyles: false),
                              const InsertButtons(),
                              const OtherButtons(
                                fullscreen: false,
                                undo: false,
                                redo: false,
                                copy: false,
                                paste: false,
                                help: false,
                              ),
                            ],
                            customToolbarButtons: [
                              MyHtmlColor()
                                  .colorButton(controller: _htmlEditorController, color: MyStrings.red),
                              MyHtmlColor()
                                  .colorButton(controller: _htmlEditorController, color: MyStrings.blue),
                              MyHtmlColor()
                                  .colorButton(controller: _htmlEditorController, color: MyStrings.black),
                            ],
                          ),
                          callbacks: Callbacks(onChangeContent: (String? content) {
                            notice.contents = content!;
                          }),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                String title = _textEditingController.text;
                _textEditingController.dispose();
                _htmlEditorController.disable();
              },
              child: const Text('만들기'),
            ),
          ],
        );
      },
    );
  }

  Future<void> selectDate(BuildContext context, Message notice) async {
    DateTime deadLine = notice.deadLine!;
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: deadLine,
      firstDate: DateTime(1958),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      deadLine = pickedDate;
      _controller.update();
    }
  }

  void getDialog({
    required BuildContext context,
    required String title,
    required String content,
    required Function() functionNo,
    required Function() functionYes,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: functionNo, child: const Text('아니요')),
          TextButton(onPressed: functionYes, child: const Text('네')),
        ],
      ),
    );
  }
}
