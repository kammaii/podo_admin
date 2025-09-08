import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/common/deepl_translator.dart';
import 'package:podo_admin/common/languages.dart';
import 'package:podo_admin/common/my_radio_btn.dart';
import 'package:podo_admin/screens/korean_bites/korean_bite.dart';
import 'package:podo_admin/screens/korean_bites/korean_bite_detail.dart';
import 'package:podo_admin/screens/korean_bites/korean_bite_state_manager.dart';
import 'package:podo_admin/screens/podo_words/podo_words_state_manager.dart';
import 'package:podo_admin/screens/podo_words/topic.dart';
import 'package:podo_admin/screens/podo_words/words_detail.dart';
import 'package:responsive_framework/responsive_framework.dart';

class TopicsMain extends StatefulWidget {
  const TopicsMain({super.key});

  @override
  State<TopicsMain> createState() => _TopicsMainState();
}

class _TopicsMainState extends State<TopicsMain> {
  late PodoWordsStateManager controller;
  late Topic selectedTopic;
  String? searchedTitleNo;

  @override
  void initState() {
    super.initState();
    controller = Get.put(PodoWordsStateManager());
  }

  Widget getTitleLine(String lang) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
          child: Text(lang),
        ),
        Expanded(
          child: TextField(
            controller: TextEditingController(text: selectedTopic.title),
            onChanged: (value) {
              selectedTopic.title = value;
            },
          ),
        ),
      ],
    );
  }

  Future uploadImage(Topic topic) async {
    final pickedFile = await FilePicker.platform.pickFiles(type: FileType.image);

    if (pickedFile != null) {
      Uint8List? imageBytes = pickedFile.files.single.bytes;
      if (imageBytes != null) {
        String base64Image = base64Encode(imageBytes);
        topic.image = base64Image;
        controller.update();
      } else {
        print('Failed to read image file.');
      }
    } else {
      print('No image selected.');
    }
  }

  void openTopicDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Topic'),
        content: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: GetBuilder<PodoWordsStateManager>(
              builder: (_) {
                Topic topic = selectedTopic;

                return SizedBox(
                  width: 500,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 100,
                              child: Text('Title'),
                            ),
                            Expanded(
                              child: TextField(
                                controller: TextEditingController(text: selectedTopic.title),
                                onChanged: (value) {
                                  selectedTopic.title = value;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Column(
                          children: [
                            topic.image != null
                                ? Stack(
                                    children: [
                                      Image.memory(base64Decode(topic.image!), height: 100, width: 100),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: IconButton(
                                          alignment: Alignment.topRight,
                                          padding: const EdgeInsets.all(0),
                                          icon: const Icon(Icons.remove_circle_outline_outlined),
                                          color: Colors.red,
                                          onPressed: () {
                                            topic.image = null;
                                            controller.update();
                                          },
                                        ),
                                      ),
                                    ],
                                  )
                                : const Icon(Icons.error),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                uploadImage(topic);
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                child: Text('이미지 업로드'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                              onPressed: () async {
                                Get.back();
                                await controller.addTopic(topic);
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(10),
                                child: Text('저장'),
                              )),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Podo Words'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: StreamBuilder<List<Topic>>(
            stream: controller.getTopicsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('토픽이 없습니다.'));
              }

              final topics = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      selectedTopic = Topic(topics.length);
                      openTopicDialog();
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Text(
                        '추가하기',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: DataTable2(
                      columns: const [
                        DataColumn2(label: Text('순서'), size: ColumnSize.S),
                        DataColumn2(label: Text('아이디'), size: ColumnSize.S),
                        DataColumn2(label: Text('타이틀'), size: ColumnSize.S),
                        DataColumn2(label: Text('상태'), size: ColumnSize.S),
                        DataColumn2(label: Text('순서변경'), size: ColumnSize.S),
                        DataColumn2(label: Text('삭제'), size: ColumnSize.S),
                        DataColumn2(label: Text(''), size: ColumnSize.S),
                      ],
                      rows: List<DataRow>.generate(topics.length, (index) {
                        Topic topic = topics[index];
                        return DataRow(cells: [
                          DataCell(Text(topic.orderId.toString())),
                          DataCell(Text(topic.id.substring(0, 8)), onTap: () {
                            Clipboard.setData(ClipboardData(text: topic.id));
                            Get.snackbar('아이디가 클립보드에 저장되었습니다.', topic.id, snackPosition: SnackPosition.BOTTOM);
                          }),
                          DataCell(Text(topic.title), onTap: () {
                            selectedTopic = topic;
                            openTopicDialog();
                          }),
                          DataCell(Icon(Icons.circle, color: topic.isReleased ? Colors.green : Colors.red),
                              onTap: () {
                            Get.dialog(AlertDialog(
                              content: const Text('상태를 변경하겠습니까?'),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Get.back();
                                      topic.isReleased = true;
                                      controller.updateTopic(topic);
                                    },
                                    child: const Text('게시중')),
                                TextButton(
                                    onPressed: () {
                                      Get.back();
                                      topic.isReleased = false;
                                      controller.updateTopic(topic);
                                    },
                                    child: const Text('입력중')),
                              ],
                            ));
                          }),
                          DataCell(
                            Row(
                              children: [
                                Expanded(
                                  child: IconButton(
                                      // 위로
                                      onPressed: () async {
                                        if (index == 0) {
                                          Get.dialog(const AlertDialog(
                                            title: Text('마지막 레슨입니다.'),
                                          ));
                                        } else {
                                          controller.switchTopicsOrder(topic1: topic, topic2: topics[index-1]);
                                        }
                                      },
                                      icon: const Icon(Icons.arrow_drop_up_outlined)),
                                ),
                                Expanded(
                                  child: IconButton(
                                      // 아래로
                                      onPressed: () async {
                                        if (index == topics.length - 1) {
                                          Get.dialog(const AlertDialog(
                                            title: Text('첫번째 레슨입니다.'),
                                          ));
                                        } else {
                                          controller.switchTopicsOrder(topic1: topic, topic2: topics[index+1]);
                                        }
                                      },
                                      icon: const Icon(Icons.arrow_drop_down_outlined)),
                                ),
                              ],
                            ),
                          ),
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
                                        onPressed: () async {
                                          Get.back();
                                          controller.removeTopic(topic);
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
                          DataCell(ElevatedButton(
                            child: const Text('상세'),
                            onPressed: () {
                              Get.to(const WordsDetail(), arguments: topic.id);
                            },
                          )),
                        ]);
                      }),
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }
}
