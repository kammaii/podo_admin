import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
import 'package:podo_admin/screens/podo_words/word.dart';
import 'package:podo_admin/screens/podo_words/words_main.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../common/recording_widget.dart';

class WordsMain extends StatefulWidget {
  const WordsMain({super.key});

  @override
  State<WordsMain> createState() => _WordsMainState();
}

class _WordsMainState extends State<WordsMain> {
  PodoWordsStateManager controller = Get.find<PodoWordsStateManager>();
  String topicId = Get.arguments;
  late Word selectedWord;
  final FirebaseApp podoWordsFirebase = Firebase.app('podoWords');
  late final FirebaseStorage podoWordsStorage;
  final FirebaseFirestore db = FirebaseFirestore.instanceFor(app: Firebase.app('podoWords'));


  @override
  void initState() {
    super.initState();
    podoWordsStorage = FirebaseStorage.instanceFor(
        app: podoWordsFirebase,
        bucket: 'podo-words.firebasestorage.app',
    );
  }

  Widget getInputLine(String title, TextEditingController tec, Function(String) f) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
          child: Text(title),
        ),
        Expanded(
          child: TextField(
            controller: tec,
            onChanged: f,
          ),
        ),
      ],
    );
  }

  Future uploadImage(Word word) async {
    final pickedFile = await FilePicker.platform.pickFiles(type: FileType.image);

    if (pickedFile != null) {
      Uint8List? imageBytes = pickedFile.files.single.bytes;
      if (imageBytes != null) {
        String base64Image = base64Encode(imageBytes);
        word.image = base64Image;
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
        title: const Text('Word'),
        content: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: GetBuilder<PodoWordsStateManager>(
              builder: (_) {
                Word word = selectedWord;

                return SizedBox(
                  width: 500,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        getInputLine('Front', TextEditingController(text: word.front), (val) {
                          word.front = val;
                        }),
                        getInputLine('Back', TextEditingController(text: word.back), (val) {
                          word.back = val;
                        }),getInputLine('Pronunciation', TextEditingController(text: word.pronunciation), (val) {
                          word.pronunciation = val;
                        }),
                        //todo: 오디오 입력 기능
                        const SizedBox(height: 20),
                        Column(
                          children: [
                            word.image != null
                                ? Stack(
                              children: [
                                Image.memory(base64Decode(word.image!), height: 100, width: 100),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    alignment: Alignment.topRight,
                                    padding: const EdgeInsets.all(0),
                                    icon: const Icon(Icons.remove_circle_outline_outlined),
                                    color: Colors.red,
                                    onPressed: () {
                                      word.image = null;
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
                                uploadImage(word);
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
                                await controller.addWord(topicId, word);
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
        child: StreamBuilder<List<Word>>(
            stream: controller.getWordsStream(topicId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        selectedWord = Word(0);
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
                    const Expanded(child: Center(child: Text('단어가 없습니다.'))),
                  ],
                );
              }

              final words = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      selectedWord = Word(words.length);
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
                      dataRowHeight: 120,
                      columns: const [
                        DataColumn2(label: Text('순서'), size: ColumnSize.S),
                        DataColumn2(label: Text('아이디'), size: ColumnSize.S),
                        DataColumn2(label: Text('이미지'), size: ColumnSize.S),
                        DataColumn2(label: Text('단어'), size: ColumnSize.S),
                        DataColumn2(label: Text('발음'), size: ColumnSize.S),
                        DataColumn2(label: Text('오디오'), size: ColumnSize.L),
                        DataColumn2(label: Text('상태'), size: ColumnSize.S),
                        DataColumn2(label: Text('순서변경'), size: ColumnSize.S),
                        DataColumn2(label: Text('삭제'), size: ColumnSize.S),
                      ],
                      rows: List<DataRow>.generate(words.length, (index) {
                        Word word = words[index];
                        return DataRow(cells: [
                          DataCell(Text(word.orderId.toString())),
                          DataCell(Text(word.id.substring(0, 8)), onTap: () {
                            Clipboard.setData(ClipboardData(text: word.id));
                            Get.snackbar('아이디가 클립보드에 저장되었습니다.', word.id, snackPosition: SnackPosition.BOTTOM);
                          }),
                          DataCell(word.image != null ? Image.memory(base64Decode(word.image!), height: 80, width: 80) : const SizedBox.shrink()),
                          DataCell(Text('${word.front} : ${word.back}'), onTap: () {
                            selectedWord = word;
                            openTopicDialog();
                          }),
                          DataCell(Text(word.pronunciation), onTap: () {
                            selectedWord = word;
                            openTopicDialog();
                          }),
                          DataCell(RecordingWidget(path: 'audios/$topicId/${word.id}', storage: podoWordsStorage, db: db)),
                          DataCell(Icon(Icons.circle, color: word.isReleased ? Colors.green : Colors.red),
                              onTap: () {
                                Get.dialog(AlertDialog(
                                  content: const Text('상태를 변경하겠습니까?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Get.back();
                                          word.isReleased = true;
                                          controller.updateWord(topicId, word);
                                        },
                                        child: const Text('게시중')),
                                    TextButton(
                                        onPressed: () {
                                          Get.back();
                                          word.isReleased = false;
                                          controller.updateWord(topicId, word);
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
                                            title: Text('마지막 단어입니다.'),
                                          ));
                                        } else {
                                          controller.switchWordsOrder(topicId: topicId, word1: word, word2: words[index-1]);
                                        }
                                      },
                                      icon: const Icon(Icons.arrow_drop_up_outlined)),
                                ),
                                Expanded(
                                  child: IconButton(
                                    // 아래로
                                      onPressed: () async {
                                        if (index == words.length - 1) {
                                          Get.dialog(const AlertDialog(
                                            title: Text('첫번째 단어입니다.'),
                                          ));
                                        } else {
                                          controller.switchWordsOrder(topicId: topicId, word1: word, word2: words[index+1]);
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
                                          controller.removeWordAndReorder(topicId, word);
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
