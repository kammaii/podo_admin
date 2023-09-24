import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/common/gpt_translator.dart';
import 'package:podo_admin/common/languages.dart';
import 'package:podo_admin/common/my_radio_btn.dart';
import 'package:podo_admin/common/my_textfield.dart';
import 'package:podo_admin/screens/reading/reading_title.dart';
import 'package:podo_admin/screens/reading/reading_detail.dart';
import 'package:podo_admin/screens/reading/reading_state_manager.dart';

class ReadingTitleMain extends StatefulWidget {
  ReadingTitleMain({Key? key}) : super(key: key);

  @override
  State<ReadingTitleMain> createState() => _ReadingTitleMainState();
}

class _ReadingTitleMainState extends State<ReadingTitleMain> {
  late ReadingStateManager controller;
  final READING_TITLES = 'ReadingTitles';
  late ReadingTitle selectedReadingTitle;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ReadingStateManager());
    getDataFromDb();
  }

  getDataFromDb() {
    if (controller.selectedCategory == controller.categories[4]) {
      controller.futureList = Database().getDocs(collection: READING_TITLES, orderBy: 'orderId', descending: false);
    } else {
      controller.futureList = Database().getDocs(
          collection: READING_TITLES, field: 'category', equalTo: controller.selectedCategory, orderBy: 'orderId', descending: false);
    }
  }

  updateDB({required String collection, required String docId, required Map<String, dynamic> value}) async {
    Get.back();
    await Database().updateField(collection: collection, docId: docId, map: value);
    setState(() {
      getDataFromDb();
    });
  }

  Widget getCategoryRadioBtn(String value) {
    return MyRadioBtn().getRadioButton(
      width: 200,
      context: context,
      value: value,
      groupValue: controller.selectedCategory,
      f: (String? value) {
        controller.selectedCategory = value!;
        setState(() {
          getDataFromDb();
        });
      },
    );
  }

  Widget getTitleLine(String lang) {
    String text = selectedReadingTitle.title[lang] ?? '';
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
              selectedReadingTitle.title[lang] = value;
            },
          ),
        ),
      ],
    );
  }

  Future uploadImage(ReadingTitle readingTitle) async {
    final pickedFile = await FilePicker.platform.pickFiles(type: FileType.image);

    if (pickedFile != null) {
      Uint8List? imageBytes = pickedFile.files.single.bytes;
      if (imageBytes != null) {
        String base64Image = base64Encode(imageBytes);
        readingTitle.image = base64Image;
        controller.update();
      } else {
        print('Failed to read image file.');
      }
    } else {
      print('No image selected.');
    }
  }

  void openReadingTitleDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('읽기 타이틀 추가하기'),
        content: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: GetBuilder<ReadingStateManager>(
              builder: (_) {
                ReadingTitle readingTitle = selectedReadingTitle;

                return SizedBox(
                  width: 500,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                const Text('레벨', textScaleFactor: 1.5),
                                DropdownButton(
                                  value: controller.readingLevel[readingTitle.level],
                                  icon: const Icon(Icons.arrow_drop_down_outlined),
                                  items: controller.readingLevel.map<DropdownMenuItem<String>>((value) {
                                    return DropdownMenuItem(value: value, child: Text(value));
                                  }).toList(),
                                  onChanged: (value) {
                                    readingTitle.level = controller.readingLevel.indexOf(value.toString());
                                    controller.update();
                                  },
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                const Text('카테고리', textScaleFactor: 1.5),
                                DropdownButton(
                                  value: readingTitle.category,
                                  icon: const Icon(Icons.arrow_drop_down_outlined),
                                  items: controller.categories.map<DropdownMenuItem<String>>((value) {
                                    return DropdownMenuItem(value: value, child: Text(value));
                                  }).toList(),
                                  onChanged: (value) {
                                    readingTitle.category = value.toString();
                                    controller.update();
                                  },
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                readingTitle.image != null
                                    ? Stack(
                                        children: [
                                          Image.memory(base64Decode(readingTitle.image!), height: 100, width: 100),
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: IconButton(
                                              alignment: Alignment.topRight,
                                              padding: const EdgeInsets.all(0),
                                              icon: const Icon(Icons.remove_circle_outline_outlined),
                                              color: Colors.red,
                                              onPressed: () {
                                                readingTitle.image = null;
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
                                    uploadImage(readingTitle);
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    child: Text('이미지 업로드'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Text('읽기 타이틀', textScaleFactor: 1.5),
                            const SizedBox(width: 10),
                            TextButton(onPressed: (){
                              GPTTranslator().getTranslations(readingTitle.title).then((value) => controller.update());
                            }, child: const Text('번역')),
                          ],
                        ),
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
                        const SizedBox(height: 30),
                        Center(
                          child: ElevatedButton(
                              onPressed: () async {
                                Get.back();
                                await Database().setDoc(collection: 'ReadingTitles', doc: selectedReadingTitle);
                                controller.getTotalLength();
                                setState(() {
                                  getDataFromDb();
                                });
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
        title: const Text('읽기 타이틀'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    getCategoryRadioBtn(controller.categories[0]),
                    getCategoryRadioBtn(controller.categories[1]),
                    getCategoryRadioBtn(controller.categories[2]),
                    getCategoryRadioBtn(controller.categories[3]),
                    getCategoryRadioBtn(controller.categories[4]),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    selectedReadingTitle = ReadingTitle();
                    openReadingTitleDialog();
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      '추가하기',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: readingTable(),
            ),
          ],
        ),
      ),
    );
  }

  Widget readingTable() {
    return FutureBuilder(
      future: controller.futureList,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData && snapshot.connectionState != ConnectionState.waiting) {
          controller.readingTitles = [];
          for (dynamic snapshot in snapshot.data) {
            controller.readingTitles.add(ReadingTitle.fromJson(snapshot));
          }
          List<ReadingTitle> readingTitles = controller.readingTitles;
          if (readingTitles.isEmpty) {
            return const Center(child: Text('검색된 읽기 타이틀이 없습니다.'));
          } else {
            return DataTable2(
              columns: const [
                DataColumn2(label: Text('순서ID'), size: ColumnSize.S),
                DataColumn2(label: Text('아이디'), size: ColumnSize.S),
                DataColumn2(label: Text('타이틀'), size: ColumnSize.L),
                DataColumn2(label: Text('레벨'), size: ColumnSize.S),
                DataColumn2(label: Text('태그'), size: ColumnSize.S),
                DataColumn2(label: Text('상태'), size: ColumnSize.S),
                DataColumn2(label: Text('무료'), size: ColumnSize.S),
                DataColumn2(label: Text('순서변경'), size: ColumnSize.S),
                DataColumn2(label: Text('삭제'), size: ColumnSize.S),
                DataColumn2(label: Text(''), size: ColumnSize.S),
              ],
              rows: List<DataRow>.generate(readingTitles.length, (i) {
                int index = readingTitles.length - 1 - i;
                ReadingTitle readingTitle = readingTitles[index];
                return DataRow(cells: [
                  DataCell(Text(readingTitle.orderId.toString())),
                  DataCell(Text(readingTitle.id.substring(0, 8)), onTap: () {
                    Clipboard.setData(ClipboardData(text: readingTitle.id));
                    Get.snackbar('아이디가 클립보드에 저장되었습니다.', readingTitle.id, snackPosition: SnackPosition.BOTTOM);
                  }),
                  DataCell(Text(readingTitle.title['ko'] ?? ''), onTap: () {
                    selectedReadingTitle = readingTitle;
                    openReadingTitleDialog();
                  }),
                  DataCell(Text(controller.readingLevel[readingTitle.level])),
                  DataCell(Text(readingTitle.tag.isNotEmpty ? readingTitle.tag.toString() : ''), onTap: () {
                    Get.dialog(
                      AlertDialog(
                        title: const Text('태그를 입력하세요'),
                        content: MyTextField().getTextField(
                            controller: TextEditingController(text: readingTitle.tag),
                            fn: (String? value) {
                              readingTitle.tag = value!;
                            }),
                        actions: [
                          TextButton(
                              onPressed: () {
                                updateDB(
                                    collection: READING_TITLES,
                                    docId: readingTitle.id,
                                    value: {'tag': readingTitle.tag});
                              },
                              child: const Text('저장'))
                        ],
                      ),
                    );
                  }),
                  DataCell(Icon(Icons.circle, color: readingTitle.isReleased ? Colors.green : Colors.red),
                      onTap: () {
                    Get.dialog(AlertDialog(
                      content: const Text('상태를 변경하겠습니까?'),
                      actions: [
                        TextButton(
                            onPressed: () {
                              updateDB(
                                  collection: READING_TITLES, docId: readingTitle.id, value: {'isReleased': true});
                            },
                            child: const Text('게시중')),
                        TextButton(
                            onPressed: () {
                              updateDB(
                                  collection: READING_TITLES,
                                  docId: readingTitle.id,
                                  value: {'isReleased': false});
                            },
                            child: const Text('입력중')),
                      ],
                    ));
                  }),
                  DataCell(
                      Icon(readingTitle.isFree ? CupertinoIcons.check_mark_circled : CupertinoIcons.xmark_circle,
                          color: readingTitle.isFree ? Colors.green : Colors.red), onTap: () {
                    Get.dialog(AlertDialog(
                      content: const Text('상태를 변경하겠습니까?'),
                      actions: [
                        TextButton(
                            onPressed: () {
                              updateDB(
                                  collection: READING_TITLES, docId: readingTitle.id, value: {'isFree': true});
                            },
                            child: const Text('무료')),
                        TextButton(
                            onPressed: () {
                              updateDB(
                                  collection: READING_TITLES, docId: readingTitle.id, value: {'isFree': false});
                            },
                            child: const Text('유료')),
                      ],
                    ));
                  }),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                            onPressed: () async {
                              if (index != 0) {
                                int newIndex = index - 1;
                                ReadingTitle thatReading = readingTitles[newIndex];
                                await Database().switchOrderTransaction(
                                    collection: READING_TITLES, docId1: readingTitle.id, docId2: thatReading.id);
                                setState(() {
                                  getDataFromDb();
                                });
                              } else {
                                Get.dialog(const AlertDialog(
                                  title: Text('첫번째 읽기입니다.'),
                                ));
                              }
                            },
                            icon: const Icon(Icons.arrow_drop_up_outlined)),
                        IconButton(
                            onPressed: () async {
                              if (index != readingTitles.length - 1) {
                                int newIndex = index + 1;
                                ReadingTitle thatReading = readingTitles[newIndex];
                                await Database().switchOrderTransaction(
                                    collection: READING_TITLES, docId1: readingTitle.id, docId2: thatReading.id);
                                setState(() {
                                  getDataFromDb();
                                });
                              } else {
                                Get.dialog(const AlertDialog(
                                  title: Text('마지막 레슨입니다.'),
                                ));
                              }
                            },
                            icon: const Icon(Icons.arrow_drop_down_outlined)),
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
                                  await Database().deleteListAndReorderBatch(
                                      collection: READING_TITLES, index: index, list: readingTitles);
                                  controller.getTotalLength();
                                  setState(() {
                                    getDataFromDb();
                                  });
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
                    child: const Text('상세보기'),
                    onPressed: () {
                      Get.to(const ReadingDetail(), arguments: readingTitle);
                    },
                  ))
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
    );
  }
}
