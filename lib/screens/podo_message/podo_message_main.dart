import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/common/languages.dart';
import 'package:podo_admin/common/my_date_format.dart';
import 'package:podo_admin/common/my_html_color.dart';
import 'package:podo_admin/screens/podo_message/podo_message.dart';
import 'package:podo_admin/screens/podo_message/podo_message_reply_main.dart';
import 'package:podo_admin/screens/podo_message/podo_message_state_manager.dart';
import 'package:podo_admin/screens/value/my_strings.dart';

class PodoMessageMain extends StatelessWidget {
  PodoMessageMain({Key? key}) : super(key: key);
  final PodoMessageStateManager _controller = Get.put(PodoMessageStateManager());
  late HtmlEditorController _htmlEditorController;
  late PodoMessage selectedMsg;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.getMessages();
    });
    DateTime now = DateTime.now();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          getMessageDialog(context);
        },
        icon: const Icon(Icons.add_circle_outline_rounded),
        label: const Text('메시지 만들기'),
      ),
      appBar: AppBar(
        title: const Text('포도 메시지'),
      ),
      body: GetBuilder<PodoMessageStateManager>(
        builder: (controller) {
          if (_controller.messages.isNotEmpty) {
            return DataTable2(
              columns: const [
                DataColumn2(label: Text('No'), size: ColumnSize.S),
                DataColumn2(label: Text('제목'), size: ColumnSize.L),
                DataColumn2(label: Text('시작'), size: ColumnSize.S),
                DataColumn2(label: Text('종료'), size: ColumnSize.S),
                DataColumn2(label: Text('상태'), size: ColumnSize.S),
                DataColumn2(label: Text('선정/미선정'), size: ColumnSize.S),
                DataColumn2(label: Text('게시'), size: ColumnSize.S),
                DataColumn2(label: Text('삭제'), size: ColumnSize.S),
                DataColumn2(label: Text(''), size: ColumnSize.S),
              ],
              rows: List<DataRow>.generate(controller.messages.length, (index) {
                PodoMessage message = controller.messages[index];
                String status = '';
                if(message.dateStart != null && message.dateEnd != null) {
                  if(now.isAfter(message.dateStart!) && now.isBefore(message.dateEnd!)) {
                    status = '진행중';
                  } else if(now.isAfter(message.dateEnd!)) {
                    status = '종료';
                  }
                }

                return DataRow(cells: [
                  DataCell(Text((controller.messages.length - index).toString())),
                  DataCell(Text(message.title['ko'] ?? ''), onTap: () {
                    selectedMsg = message;
                    getMessageDialog(context, isNew: false);
                  }),
                  message.dateStart != null
                      ? DataCell(Text(MyDateFormat().getDateOnlyFormat(message.dateStart!)))
                      : const DataCell(Text('-')),
                  message.dateEnd != null
                      ? DataCell(Text(MyDateFormat().getDateOnlyFormat(message.dateEnd!)))
                      : const DataCell(Text('-')),
                  DataCell(Text(status)),
                  message.id == controller.messageIdForReplyCount
                      ? DataCell(Text('${controller.replyStatusCount[0]} / ${controller.replyStatusCount[1]}'))
                      : DataCell(ElevatedButton(
                          child: const Text('확인'),
                          onPressed: () {
                            controller.getReplyCount(messageId: message.id);
                          },
                        )),
                  DataCell(Checkbox(
                    value: message.isActive,
                    onChanged: (bool? value) {
                      String title = value! ? '메시지 활성화' : '메시지 비활성화';
                      String content = value ? '이 메시지를 활성화 하겠습니까?' : '이 메시지를 비활성화 하겠습니까?';
                      getDialog(
                        title: title,
                        content: content,
                        functionNo: () {
                          Get.back();
                        },
                        functionYes: () {
                          Get.back();
                          if (value) {
                            bool hasActiveMessage = false;
                            for (PodoMessage message in _controller.messages) {
                              if (message.isActive) {
                                hasActiveMessage = true;
                              }
                            }
                            if (hasActiveMessage) {
                              Get.dialog(const AlertDialog(
                                title: Text('에러'),
                                content: Text('이미 게시된 메시지가 있습니다.'),
                              ));
                            } else {
                              controller.setMessageActive(index, value);
                            }
                          } else {
                            controller.setMessageActive(index, value);
                          }
                        },
                      );
                    },
                  )),
                  DataCell(IconButton(
                    icon: const Icon(Icons.delete),
                    color: Colors.red,
                    onPressed: () {
                      getDialog(
                        title: '메시지삭제',
                        content: '이 메시지를 삭제하겠습니까?',
                        functionNo: () {
                          Get.back();
                        },
                        functionYes: () {
                          Get.back();
                          controller.deleteMessage(index);
                        },
                      );
                    },
                  )),
                  DataCell(ElevatedButton(
                    child: const Text('답변보기'),
                    onPressed: () {
                      controller.selectedMessageId = message.id;
                      Get.to(CloudMessageReplyMain(), arguments: message.title['ko']);
                    },
                  ))
                ]);
              }),
            );
          } else {
            return const Center(child: Text('검색된 클라우드 메시지가 없습니다.'));
          }
        },
      ),
    );
  }

  Widget getTitleLine(String lang) {
    String text = selectedMsg.title[lang] ?? '';
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
          child: Text(lang),
        ),
        Expanded(
          child: TextField(
            controller: TextEditingController(text: text),
            onChanged: (value) {
              selectedMsg.title[lang] = value;
            },
          ),
        ),
      ],
    );
  }

  void getMessageDialog(BuildContext context, {bool isNew = true}) {
    _htmlEditorController = HtmlEditorController();
    if (isNew) {
      selectedMsg = PodoMessage();
    }
    if (selectedMsg.content != null) {
      _controller.isContentChecked = true;
    } else {
      _controller.isContentChecked = false;
    }
    Get.dialog(
      AlertDialog(
        title: const Text('메시지 상세보기'),
        content: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: GetBuilder<PodoMessageStateManager>(
              builder: (_) {
                return SizedBox(
                  width: 500,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('제목', textScaleFactor: 1.5),
                      getTitleLine('ko'),
                      const SizedBox(height: 10),
                      getTitleLine(Languages().getFos[0]),
                      const SizedBox(height: 10),
                      getTitleLine(Languages().getFos[1]),
                      const SizedBox(height: 10),
                      getTitleLine(Languages().getFos[2]),
                      const SizedBox(height: 10),
                      getTitleLine(Languages().getFos[3]),
                      const SizedBox(height: 10),
                      getTitleLine(Languages().getFos[4]),
                      const SizedBox(height: 10),
                      getTitleLine(Languages().getFos[5]),
                      const SizedBox(height: 10),
                      getTitleLine(Languages().getFos[6]),
                      const SizedBox(height: 20),
                      const Text('시작일', textScaleFactor: 1.5),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          selectedMsg.dateStart != null
                              ? Text(MyDateFormat().getDateOnlyFormat(selectedMsg.dateStart!))
                              : const Text('없음'),
                          const SizedBox(width: 10),
                          ElevatedButton(
                              onPressed: () async {
                                final DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1958),
                                  lastDate: DateTime(2030),
                                );
                                if (pickedDate != null) {
                                  selectedMsg.dateStart = pickedDate;
                                  _controller.update();
                                }
                              },
                              child: const Text('날짜설정')),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text('종료일', textScaleFactor: 1.5),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          selectedMsg.dateEnd != null
                              ? Text(MyDateFormat().getDateOnlyFormat(selectedMsg.dateEnd!))
                              : const Text('없음'),
                          const SizedBox(width: 10),
                          ElevatedButton(
                              onPressed: () async {
                                final DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1958),
                                  lastDate: DateTime(2030),
                                );
                                if (pickedDate != null) {
                                  selectedMsg.dateEnd = pickedDate;
                                  _controller.update();
                                }
                              },
                              child: const Text('날짜설정')),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Text('내용 (optional)', textScaleFactor: 1.5),
                          const SizedBox(width: 10),
                          Checkbox(
                              value: _controller.isContentChecked,
                              onChanged: (value) {
                                _controller.isContentChecked = value!;
                                _controller.update();
                              }),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Visibility(
                        visible: _controller.isContentChecked,
                        child: Container(
                          width: 500,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                          ),
                          child: HtmlEditor(
                            controller: _htmlEditorController,
                            htmlEditorOptions: HtmlEditorOptions(initialText: selectedMsg.content),
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
                                MyHtmlColor().colorButton(controller: _htmlEditorController, color: MyStrings.red),
                                MyHtmlColor()
                                    .colorButton(controller: _htmlEditorController, color: MyStrings.blue),
                                MyHtmlColor()
                                    .colorButton(controller: _htmlEditorController, color: MyStrings.black),
                              ],
                            ),
                            callbacks: Callbacks(onChangeContent: (String? content) {
                              selectedMsg.content = content!;
                            }),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                            onPressed: () async {
                              Get.back();
                              _controller.saveMessage(selectedMsg);
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Text('저장'),
                            )),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void getDialog({
    required String title,
    required String content,
    required Function() functionNo,
    required Function() functionYes,
  }) {
    Get.dialog(
      AlertDialog(
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
