import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/common/deepl_translator.dart';
import 'package:podo_admin/common/languages.dart';
import 'package:podo_admin/common/my_radio_btn.dart';
import 'package:podo_admin/common/my_textfield.dart';
import 'package:podo_admin/screens/korean_bites/korean_bite.dart';
import 'package:podo_admin/screens/korean_bites/korean_bite_detail.dart';
import 'package:podo_admin/screens/korean_bites/korean_bite_state_manager.dart';

class KoreanBiteTitleMain extends StatefulWidget {
  const KoreanBiteTitleMain({super.key});

  @override
  State<KoreanBiteTitleMain> createState() => _KoreanBitesTitleMainState();
}

class _KoreanBitesTitleMainState extends State<KoreanBiteTitleMain> {
  late KoreanBiteStateManager controller;
  final KOREAN_BITES = 'KoreanBites';
  late KoreanBite selectedKoreanBite;

  @override
  void initState() {
    super.initState();
    controller = Get.find<KoreanBiteStateManager>();
    getDataFromDb();
  }

  getDataFromDb() {
    if (controller.selectedCategory == 'All') {
      controller.futureKoreanBite = Database().getDocs(collection: KOREAN_BITES, orderBy: 'date', descending: true);
    } else {
      controller.futureKoreanBite = Database().getDocs(
          collection: KOREAN_BITES,
          field: 'tags',
          arrayContains: controller.selectedCategory,
          orderBy: 'date',
          descending: true);
    }
  }

  Widget getCategoryRadioBtn(String value) {
    return Expanded(
      child: MyRadioBtn().getRadioButton(
        context: context,
        value: value,
        groupValue: controller.selectedCategory,
        f: (String? value) {
          controller.selectedCategory = value!;
          setState(() {
            getDataFromDb();
          });
        },
      ),
    );
  }

  Widget getTitleLine(String lang) {
    String text = selectedKoreanBite.title[lang] ?? '';
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
              selectedKoreanBite.title[lang] = value;
            },
          ),
        ),
      ],
    );
  }

  void openKoreanBiteDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Korean Bite 타이틀'),
        content: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: GetBuilder<KoreanBiteStateManager>(
              builder: (_) {
                KoreanBite koreanBite = selectedKoreanBite;

                return SizedBox(
                  width: 500,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        getTitleLine('ko'),
                        const SizedBox(height: 10),
                        DeeplTranslator().getTransBtn(controller, koreanBite.title),
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
                                await Database().setDoc(collection: 'KoreanBites', doc: koreanBite);
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

  updateDB({required String collection, required String docId, required Map<String, dynamic> value}) async {
    Get.back();
    await Database().updateField(collection: collection, docId: docId, map: value);
    setState(() {
      getDataFromDb();
    });
  }

  Widget koreanBiteTable() {
    return FutureBuilder(
      future: controller.futureKoreanBite,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData && snapshot.connectionState != ConnectionState.waiting) {
          controller.koreanBites = [];
          for (dynamic snapshot in snapshot.data) {
            controller.koreanBites.add(KoreanBite.fromJson(snapshot));
          }
          List<KoreanBite> koreanBites = controller.koreanBites;
          if (koreanBites.isEmpty) {
            return const Center(child: Text('검색된 Korean Bites 가 없습니다.'));
          } else {
            return DataTable2(
              columns: const [
                DataColumn2(label: Text('순서'), size: ColumnSize.S),
                DataColumn2(label: Text('아이디'), size: ColumnSize.S),
                DataColumn2(label: Text('타이틀'), size: ColumnSize.L),
                DataColumn2(label: Text('타이틀(영어)'), size: ColumnSize.L),
                DataColumn2(label: Text('태그'), size: ColumnSize.S),
                DataColumn2(label: Text('상태'), size: ColumnSize.S),
                DataColumn2(label: Text('삭제'), size: ColumnSize.S),
                DataColumn2(label: Text(''), size: ColumnSize.S),
              ],
              rows: List<DataRow>.generate(koreanBites.length, (i) {
                KoreanBite koreanBite = koreanBites[i];
                return DataRow(cells: [
                  DataCell(Text(koreanBite.orderId.toString())),
                  DataCell(Text(koreanBite.id.substring(0, 8)), onTap: () {
                    Clipboard.setData(ClipboardData(text: koreanBite.id));
                    Get.snackbar('아이디가 클립보드에 저장되었습니다.', koreanBite.id, snackPosition: SnackPosition.BOTTOM);
                  }),
                  DataCell(Text(koreanBite.title['ko'] ?? ''), onTap: () {
                    selectedKoreanBite = koreanBite;
                    openKoreanBiteDialog();
                  }),
                  DataCell(Text(koreanBite.title['en'] ?? ''), onTap: () {
                    selectedKoreanBite = koreanBite;
                    openKoreanBiteDialog();
                  }),
                  DataCell(Text(koreanBite.tags.join(",")), onTap: () {
                    Get.dialog(
                      StatefulBuilder(builder: (context, setDialogState) {
                        return AlertDialog(
                          title: const Text('태그를 입력하세요'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                  width: 250,
                                  height: 50,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(10), // 둥근 모서리 (선택 사항)
                                  ),
                                  child: Text(koreanBite.tags.join(", "))),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 5,
                                children: controller.tags.map((item) {
                                  bool isSelected = koreanBite.tags.contains(item);
                                  return TextButton(
                                      onPressed: () {
                                        setDialogState(() {
                                          if (!isSelected) {
                                            koreanBite.tags.add(item);
                                          }
                                        });
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(item),
                                          if (isSelected)
                                            IconButton(
                                                onPressed: () {
                                                  setDialogState(() {
                                                    koreanBite.tags.remove(item);
                                                  });
                                                },
                                                icon: const Icon(Icons.close, color: Colors.red))
                                        ],
                                      ));
                                }).toList(),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  updateDB(
                                      collection: KOREAN_BITES,
                                      docId: koreanBite.id,
                                      value: {'tags': koreanBite.tags});
                                },
                                child: const Text('저장'))
                          ],
                        );
                      }),
                    );
                  }),
                  DataCell(Icon(Icons.circle, color: koreanBite.isReleased ? Colors.green : Colors.red),
                      onTap: () {
                    Get.dialog(AlertDialog(
                      content: const Text('상태를 변경하겠습니까?'),
                      actions: [
                        TextButton(
                            onPressed: () {
                              updateDB(
                                  collection: KOREAN_BITES, docId: koreanBite.id, value: {'isReleased': true});
                            },
                            child: const Text('게시중')),
                        TextButton(
                            onPressed: () {
                              updateDB(
                                  collection: KOREAN_BITES, docId: koreanBite.id, value: {'isReleased': false});
                            },
                            child: const Text('입력중')),
                      ],
                    ));
                  }),
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
                                  FirebaseFirestore firestore = FirebaseFirestore.instance;
                                  // 모든 예문들 삭제
                                  final exampleRef = firestore.collection('KoreanBites/${koreanBite.id}/Examples');
                                  QuerySnapshot snapshot = await exampleRef.get();
                                  final batch = firestore.batch();
                                  for(QueryDocumentSnapshot doc in snapshot.docs) {
                                    batch.delete(doc.reference);
                                  }
                                  //TODO: 모든 댓글들 삭제 추가
                                  // KoreanBite 삭제
                                  final koreanBiteDoc = firestore.collection('KoreanBites').doc(koreanBite.id);
                                  batch.delete(koreanBiteDoc);

                                  batch.commit().then((_) {
                                    setState(() {
                                      Get.snackbar('Korean Bite를 삭제했습니다.', koreanBite.id, snackPosition: SnackPosition.BOTTOM);
                                      getDataFromDb();
                                    });
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
                      Get.to(const KoreanBiteDetail(), arguments: koreanBite);
                    },
                  )),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Korean Bites'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(children: [
                    getCategoryRadioBtn('All'),
                    ...controller.tags.map((item) => getCategoryRadioBtn(item)),
                  ]),
                ),
                ElevatedButton(
                  onPressed: () {
                    selectedKoreanBite = KoreanBite(controller.koreanBites.length);
                    openKoreanBiteDialog();
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
              child: koreanBiteTable(),
            ),
          ],
        ),
      ),
    );
  }
}
