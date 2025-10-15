import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
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
import 'package:responsive_framework/responsive_framework.dart';

class KoreanBiteTitleMain extends StatefulWidget {
  const KoreanBiteTitleMain({super.key});

  @override
  State<KoreanBiteTitleMain> createState() => _KoreanBitesTitleMainState();
}

class _KoreanBitesTitleMainState extends State<KoreanBiteTitleMain> {
  late KoreanBiteStateManager controller;
  final KOREAN_BITES = 'KoreanBites';
  late KoreanBite selectedKoreanBite;
  final TextEditingController _searchController = TextEditingController();
  String? searchedTitleNo;

  bool _isLoading = false;
  String _message = '';

  @override
  void initState() {
    super.initState();
    controller = Get.find<KoreanBiteStateManager>();
    getDataFromDb();
  }

  getDataFromDb() {
    if (controller.selectedTag == 'All') {
      controller.futureKoreanBite =
          Database().getDocs(collection: KOREAN_BITES, orderBy: 'date', descending: true);
    } else {
      controller.futureKoreanBite = Database().getDocs(
          collection: KOREAN_BITES,
          field: 'tags',
          arrayContains: controller.selectedTag,
          orderBy: 'date',
          descending: true);
    }
  }

  Widget getTagRadioBtn(String value) {
    return Expanded(
      child: MyRadioBtn().getRadioButton(
        context: context,
        value: value,
        groupValue: controller.selectedTag,
        f: (String? value) {
          controller.selectedTag = value!;
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
            if (ResponsiveBreakpoints.of(context).largerThan(TABLET)) {
              return DataTable2(
                columns: const [
                  DataColumn2(label: Text('순서'), size: ColumnSize.S),
                  DataColumn2(label: Text('아이디'), size: ColumnSize.S),
                  DataColumn2(label: Text('제목'), size: ColumnSize.S),
                  DataColumn2(label: Text('부제목'), size: ColumnSize.L),
                  DataColumn2(label: Text('태그'), size: ColumnSize.S),
                  DataColumn2(label: Text('좋아요'), size: ColumnSize.S),
                  DataColumn2(label: Text('상태'), size: ColumnSize.S),
                  DataColumn2(label: Text('삭제'), size: ColumnSize.S),
                  DataColumn2(label: Text(''), size: ColumnSize.S),
                  DataColumn2(label: Text('알림'), size: ColumnSize.S),
                  DataColumn2(label: Text('녹음'), size: ColumnSize.S),
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
                    DataCell(Text(koreanBite.like.toString())),
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
                                    final exampleRef =
                                        firestore.collection('KoreanBites/${koreanBite.id}/Examples');
                                    QuerySnapshot snapshot = await exampleRef.get();
                                    final batch = firestore.batch();
                                    for (QueryDocumentSnapshot doc in snapshot.docs) {
                                      batch.delete(doc.reference);
                                    }
                                    //TODO: 모든 댓글들 삭제 추가
                                    // KoreanBite 삭제
                                    final koreanBiteDoc = firestore.collection('KoreanBites').doc(koreanBite.id);
                                    batch.delete(koreanBiteDoc);

                                    batch.commit().then((_) {
                                      setState(() {
                                        Get.snackbar('Korean Bite를 삭제했습니다.', koreanBite.id,
                                            snackPosition: SnackPosition.BOTTOM);
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
                      child: const Text('상세'),
                      onPressed: () {
                        Get.to(const KoreanBiteDetail(), arguments: koreanBite);
                      },
                    )),
                    DataCell(IconButton(
                      icon: Icon(Icons.edit_notifications, color: Theme.of(context).primaryColor),
                      onPressed: () async {
                        Get.dialog(GetBuilder<KoreanBiteStateManager>(
                          builder: (controller) {
                            List<String> splitMsg = controller.selectedNoticeMsg.split(' / ');
                            String title = splitMsg[0].replaceFirst('%', koreanBite.title['ko']);
                            String content = splitMsg[1].replaceFirst('%', koreanBite.title['ko']);
                            TextEditingController titleCon = TextEditingController(text: title);
                            TextEditingController contentCon = TextEditingController(text: content);

                            return AlertDialog(
                              title: const Text('알람 메시지'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: titleCon,
                                    onChanged: (text) {
                                      title = text;
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: contentCon,
                                    onChanged: (text) {
                                      content = text;
                                    },
                                  ),
                                ],
                              ),
                              actions: [
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            Get.back();
                                            final body = {
                                              'koreanBiteId': koreanBite.id,
                                              'title': title,
                                              'content': content,
                                            };

                                            final response = await http.post(
                                              Uri.parse(
                                                  'https://us-central1-podo-49335.cloudfunctions.net/onKoreanBiteFcm'),
                                              body: body,
                                            );

                                            if (response.statusCode == 200) {
                                              print('fcm 전송 성공');
                                              Get.snackbar('알람을 전송했습니다.', koreanBite.id,
                                                  snackPosition: SnackPosition.BOTTOM);
                                            } else {
                                              print('오류 발생: ${response.statusCode}');
                                              Get.snackbar('알람을 전송을 실패 했습니다.', response.statusCode.toString(),
                                                  snackPosition: SnackPosition.BOTTOM);
                                            }
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.all(10),
                                            child: Text('보내기', style: TextStyle(fontSize: 20)),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    ...List.generate(controller.noticeMsgs.length,
                                        (index) => getMessageRadioBtn(controller.noticeMsgs[index])),
                                  ],
                                )
                              ],
                            );
                          },
                        ));
                      },
                    )),
                    DataCell(
                        Icon(Icons.audio_file_outlined,
                            color: koreanBite.hasAudio != null && koreanBite.hasAudio == true
                                ? Colors.purple
                                : Colors.grey), onTap: () {
                      Get.dialog(AlertDialog(
                        content: const Text('오디오 상태를 변경하겠습니까?'),
                        actions: [
                          TextButton(
                              onPressed: () {
                                updateDB(
                                    collection: KOREAN_BITES, docId: koreanBite.id, value: {'hasAudio': true});
                              },
                              child: const Text('오디오 있음')),
                          TextButton(
                              onPressed: () {
                                updateDB(
                                    collection: KOREAN_BITES, docId: koreanBite.id, value: {'hasAudio': false});
                              },
                              child: const Text('오디오 없음')),
                        ],
                      ));
                    }),
                  ]);
                }),
              );
            } else {
              return DataTable2(
                columns: const [
                  DataColumn2(label: Text('순서'), size: ColumnSize.S),
                  DataColumn2(label: Text('제목'), size: ColumnSize.L),
                  DataColumn2(label: Text('태그'), size: ColumnSize.S),
                  DataColumn2(label: Text('좋아요'), size: ColumnSize.S),
                  DataColumn2(label: Text('상태'), size: ColumnSize.S),
                  DataColumn2(label: Text('알림'), size: ColumnSize.S),
                ],
                rows: List<DataRow>.generate(koreanBites.length, (i) {
                  KoreanBite koreanBite = koreanBites[i];
                  return DataRow(cells: [
                    DataCell(Text(koreanBite.orderId.toString()), onTap: () {
                      Get.to(const KoreanBiteDetail(), arguments: koreanBite);
                    }),
                    DataCell(Text(koreanBite.title['ko'] ?? ''), onTap: () {
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
                    DataCell(Text(koreanBite.like.toString())),
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
                    DataCell(IconButton(
                      icon: Icon(Icons.edit_notifications, color: Theme.of(context).primaryColor),
                      onPressed: () async {
                        Get.dialog(GetBuilder<KoreanBiteStateManager>(
                          builder: (controller) {
                            List<String> splitMsg = controller.selectedNoticeMsg.split(' / ');
                            String title = splitMsg[0].replaceFirst('%', koreanBite.title['ko']);
                            String content = splitMsg[1].replaceFirst('%', koreanBite.title['ko']);
                            TextEditingController titleCon = TextEditingController(text: title);
                            TextEditingController contentCon = TextEditingController(text: content);

                            return AlertDialog(
                              title: const Text('알람 메시지'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: titleCon,
                                    onChanged: (text) {
                                      title = text;
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: contentCon,
                                    onChanged: (text) {
                                      content = text;
                                    },
                                  ),
                                ],
                              ),
                              actions: [
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            Get.back();
                                            final body = {
                                              'koreanBiteId': koreanBite.id,
                                              'title': title,
                                              'content': content,
                                            };

                                            final response = await http.post(
                                              Uri.parse(
                                                  'https://us-central1-podo-49335.cloudfunctions.net/onKoreanBiteFcm'),
                                              body: body,
                                            );

                                            if (response.statusCode == 200) {
                                              print('fcm 전송 성공');
                                              Get.snackbar('알람을 전송했습니다.', koreanBite.id,
                                                  snackPosition: SnackPosition.BOTTOM);
                                            } else {
                                              print('오류 발생: ${response.statusCode}');
                                              Get.snackbar('알람을 전송을 실패 했습니다.', response.statusCode.toString(),
                                                  snackPosition: SnackPosition.BOTTOM);
                                            }
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.all(10),
                                            child: Text('보내기', style: TextStyle(fontSize: 20)),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    ...List.generate(controller.noticeMsgs.length,
                                        (index) => getMessageRadioBtn(controller.noticeMsgs[index])),
                                  ],
                                )
                              ],
                            );
                          },
                        ));
                      },
                    ))
                  ]);
                }),
              );
            }
          }
        } else if (snapshot.hasError) {
          return Text('에러: ${snapshot.error}');
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget getMessageRadioBtn(String value) {
    return ListTile(
      title: Text(value),
      leading: Radio(
        value: value,
        activeColor: Theme.of(context).colorScheme.primary,
        groupValue: controller.selectedNoticeMsg,
        onChanged: (String? value) {
          controller.selectedNoticeMsg = value!;
          controller.update();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Korean Bites'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                // Expanded(
                //   child: ResponsiveBreakpoints.of(context).largerThan(TABLET)
                //       ? Row(children: [
                //           getTagRadioBtn('All'),
                //           ...controller.tags.map((item) => getTagRadioBtn(item)),
                //         ])
                //       : const SizedBox.shrink(),
                // ),
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
                const SizedBox(width: 50),
                Row(
                  children: [
                    SizedBox(
                      width: 200,
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          labelText: '제목',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        final searchInput = _searchController.text;
                        if (searchInput.isNotEmpty) {
                          bool found = false;

                          for (KoreanBite koreanBite in controller.koreanBites) {
                            if (koreanBite.title['ko'] == searchInput) {
                              setState(() {
                                found = true;
                                searchedTitleNo = '있음: ${koreanBite.orderId.toString()}';
                              });
                              break;
                            }
                          }
                          if (!found) {
                            setState(() {
                              searchedTitleNo = '없음';
                            });
                          }
                        }
                      },
                      child: const Text('검색'),
                    ),
                    const SizedBox(width: 10),
                    searchedTitleNo != null ? Text(searchedTitleNo.toString()) : const SizedBox.shrink(),
                  ],
                ),
                const SizedBox(width: 50),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (_isLoading) return;

                        setState(() {
                          _isLoading = true;
                          _message = '새 레슨 요청 중... 잠시만 기다려주세요.';
                        });

                        try {
                          // POST 요청 실행
                          final response = await http.post(
                            Uri.parse(
                                'https://primary-production-64dc8.up.railway.app/webhook/0a1c9667-3280-44de-95e6-c0f84a3ba6a6'),
                            headers: <String, String>{
                              // JSON 본문을 보내지 않더라도 기본 헤더를 설정하는 것이 좋습니다.
                              'Content-Type': 'application/json',
                            },
                          );

                          // 응답 상태 코드에 따라 메시지 업데이트
                          if (response.statusCode == 200) {
                            // 성공적으로 응답을 받음 (웹훅 실행 성공)
                            String responseBody = utf8.decode(response.bodyBytes);
                            setState(() {
                              _message = '성공! Slack으로 새 레슨을 전송했습니다.';
                            });
                          } else {
                            // 서버에서 오류 상태 코드를 반환
                            setState(() {
                              _message = '레슨 생성 실패! (상태 코드: ${response.statusCode})\n응답 본문: ${response.body}';
                            });
                          }
                        } catch (e) {
                          // 네트워크 연결 등 예외 발생
                          setState(() {
                            _message = '요청 중 오류 발생: $e';
                          });
                        } finally {
                          // 로딩 상태 해제
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }, // 로딩 중일 때는 버튼 비활성화
                      icon: const Icon(Icons.send_rounded),
                      label: const Text(
                        '새 레슨 요청',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 50), // 버튼 크기 설정
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 32),
                    // 로딩 인디케이터
                    if (_isLoading)
                      const CircularProgressIndicator(color: Colors.blue)
                    else
                      // 실행 결과 메시지
                      SelectableText(
                        _message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _message.contains('성공')
                              ? Colors.green.shade700
                              : _message.contains('실패')
                                  ? Colors.red.shade700
                                  : Colors.black87,
                        ),
                      ),
                  ],
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
