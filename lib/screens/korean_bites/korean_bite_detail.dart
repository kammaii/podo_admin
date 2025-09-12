import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/common/deepl_translator.dart';
import 'package:podo_admin/common/languages.dart';
import 'package:podo_admin/common/my_html_color.dart';
import 'package:podo_admin/common/my_textfield.dart';
import 'package:podo_admin/screens/korean_bites/korean_bite.dart';
import 'package:podo_admin/screens/korean_bites/korean_bite_example.dart';
import 'package:podo_admin/screens/korean_bites/korean_bite_state_manager.dart';
import 'package:podo_admin/common/recording_widget.dart';
import 'package:podo_admin/screens/value/my_strings.dart';
import 'package:responsive_framework/responsive_framework.dart';

class KoreanBiteDetail extends StatefulWidget {
  const KoreanBiteDetail({super.key});

  @override
  State<KoreanBiteDetail> createState() => _KoreanBiteDetailState();
}

class _KoreanBiteDetailState extends State<KoreanBiteDetail> {
  KoreanBite koreanBite = Get.arguments;
  final KO = 'ko';
  final FO = 'fo';
  final PRONUN = 'pronun';
  int explainFoIndex = 0;
  final _controller = Get.find<KoreanBiteStateManager>();
  final htmlEditorController = HtmlEditorController();
  late Widget explainCard;
  final ScrollController scrollController = ScrollController();
  bool isLoaded = false;
  String translatingId = '';

  void runTranslation(String id, Map<String, dynamic> map) {
    translatingId = id;
    setState(() {
      _controller.isTranslating = true;
    });
    DeeplTranslator().getTranslations(map).then((value) => setState(() {
          _controller.isTranslating = false;
        }));
  }

  // 설명 카드 세팅
  Widget getExplainCard() {
    Widget innerWidget;
    if (explainFoIndex >= Languages().getFos.length) {
      explainFoIndex = 0;
    } else if (explainFoIndex < 0) {
      explainFoIndex = Languages().getFos.length - 1;
    }
    String language = Languages().getFos[explainFoIndex];
    String explain = koreanBite.explain[language] ?? '';
    if ((_controller.isEditMode.containsKey(koreanBite.id) && _controller.isEditMode[koreanBite.id]!)) {
      htmlEditorController.setText(explain);
      innerWidget = Row(
        children: [
          IconButton(
              onPressed: () {
                setState(() {
                  explainFoIndex--;
                });
              },
              icon: const Icon(Icons.arrow_back_ios_rounded),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints()),
          Expanded(
            child: HtmlEditor(
              controller: htmlEditorController,
              htmlEditorOptions: HtmlEditorOptions(hint: MyStrings.explain, initialText: explain),
              htmlToolbarOptions: HtmlToolbarOptions(
                toolbarType: ToolbarType.nativeGrid,
                defaultToolbarButtons: [
                  const StyleButtons(),
                  const ListButtons(listStyles: false),
                  const InsertButtons(),
                  const OtherButtons(
                      fullscreen: false, undo: false, redo: false, copy: false, paste: false, help: false),
                ],
                customToolbarButtons: [
                  MyHtmlColor().colorButton(controller: htmlEditorController, color: MyStrings.red),
                  MyHtmlColor().colorButton(controller: htmlEditorController, color: MyStrings.blue),
                  MyHtmlColor().colorButton(controller: htmlEditorController, color: MyStrings.black),
                ],
              ),
              callbacks: Callbacks(onChangeContent: (String? content) {
                if (language == Languages().getFos[explainFoIndex]) {
                  koreanBite.explain[language] = content!;
                }
              }),
            ),
          ),
          IconButton(
              onPressed: () {
                setState(() {
                  explainFoIndex++;
                });
              },
              icon: const Icon(Icons.arrow_forward_ios_rounded),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints()),
        ],
      );
    } else {
      innerWidget = Text(explain);
    }
    return cardFrame(isExplain: true, innerWidget: innerWidget);
  }

  // 예문 카드 세팅
  List<Widget> getExampleCards() {
    List<Widget> exampleWidgets = List<Widget>.generate(_controller.examples.length, (index) {
      KoreanBiteExample example = _controller.examples[index];
      Widget innerWidget = Column(
        children: [
          MyTextField().getTextField(
            controller: TextEditingController(text: example.example),
            label: KO,
            autoFocus: true,
            fn: (text) {
              example.example = text;
            },
          ),
          const SizedBox(height: 5),
          MyTextField().getTextField(
            controller: TextEditingController(text: example.pronunciation),
            label: PRONUN,
            autoFocus: true,
            fn: (text) {
              example.pronunciation = text;
            },
          ),
          const Divider(height: 30),
          TextButton(
            onPressed: () {
              runTranslation(example.id, _controller.examples[index].exampleTrans);
            },
            child: Row(
              children: [
                const Text('번역'),
                const SizedBox(width: 10),
                _controller.isTranslating && example.id == translatingId
                    ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 1.5))
                    : const SizedBox.shrink()
              ],
            ),
          ),
          getFos(example.exampleTrans),
        ],
      );
      return cardFrame(isExplain: false, innerWidget: innerWidget, index: index);
    });
    return exampleWidgets;
  }

  Widget cardFrame({required bool isExplain, required Widget innerWidget, int? index}) {
    String title = isExplain ? 'Explain (${Languages().getFos[explainFoIndex]})' : 'Example';
    String widgetId = isExplain ? koreanBite.id : _controller.examples[index!].id;
    return Column(
      key: isExplain ? null : ValueKey(index),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title),
            const SizedBox(width: 10),
            isExplain
                ? TextButton(
                    onPressed: () {
                      setState(() {
                        _controller.setEditMode(id: koreanBite.id);
                      });
                    },
                    child: const Text('수정'),
                  )
                : IconButton(
                    onPressed: () {
                      setState(() {
                        _controller.examples.removeAt(index!);
                      });
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
          ],
        ),
        Text(
          isExplain ? '** 붙여넣기 시 <>클릭하고 \'Ctrl+Shift+V\', <p>태그로 감싸기 확인 **' : '한국어에 빨간색 표시는 \$\$로 감쌀것',
          style: const TextStyle(
            color: Colors.red,
            backgroundColor: Colors.yellow,
            fontWeight: FontWeight.bold,
          ),
        ),
        if(!isExplain)
          RecordingWidget(path: 'KoreanBitesAudios/${koreanBite.id}/$widgetId', storage: FirebaseStorage.instance,db: FirebaseFirestore.instance),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: 350,
                  child: SingleChildScrollView(child: innerWidget),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: widgetId));
              Get.snackbar('아이디가 클립보드에 저장되었습니다.', widgetId, snackPosition: SnackPosition.BOTTOM);
            },
            child: Text(widgetId, style: const TextStyle(color: Colors.grey))),
      ],
    );
  }

  Widget getFos(Map<String, dynamic> trans) {
    List<Widget> widgets = [];
    for (String language in Languages().getFos) {
      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: MyTextField().getTextField(
          controller: TextEditingController(text: trans[language]),
          label: language,
          autoFocus: true,
          fn: (text) {
            trans[language] = text;
          },
        ),
      ));
    }
    return Column(
      children: widgets,
    );
  }

  @override
  void initState() {
    super.initState();
    Database()
        .getDocs(collection: 'KoreanBites/${koreanBite.id}/Examples', orderBy: 'orderId', descending: false)
        .then((docs) async {
      await _controller.fetchExamples(koreanBite.id, docs);
      setState(() {
        isLoaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: koreanBite.id));
              Get.snackbar('아이디가 클립보드에 저장되었습니다.', koreanBite.id, snackPosition: SnackPosition.BOTTOM);
            },
            child: Text('Korean Bite Detail  ( ${koreanBite.title[KO]} : ${koreanBite.id.substring(0, 8)})')),
      ),
      body: isLoaded
          ? ResponsiveBreakpoints.of(context).largerThan(TABLET)
              ? Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            getExplainCard(),
                            const VerticalDivider(),
                            Expanded(
                                child: Scrollbar(
                              controller: scrollController,
                              child: ReorderableListView(
                                scrollController: scrollController,
                                padding: const EdgeInsets.all(20),
                                scrollDirection: Axis.horizontal,
                                onReorder: (int oldIndex, int newIndex) {
                                  setState(() {
                                    _controller.reorderExampleCardItem(oldIndex, newIndex);
                                  });
                                },
                                children: getExampleCards(),
                              ),
                            )),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline_rounded),
                              color: Colors.purple,
                              onPressed: () {
                                setState(() {
                                  _controller.examples.add(KoreanBiteExample(_controller.examples.length));
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(30),
                        child: ElevatedButton(
                          onPressed: () {
                            Database().runKoreanBiteBatch(koreanBite: koreanBite);
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: Text(
                              '저장',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              getExplainCard(),
                              const VerticalDivider(),
                              SizedBox(
                                  width: 800,
                                  child: Scrollbar(
                                    controller: scrollController,
                                    child: ReorderableListView(
                                      scrollController: scrollController,
                                      padding: const EdgeInsets.all(20),
                                      scrollDirection: Axis.horizontal,
                                      onReorder: (int oldIndex, int newIndex) {
                                        setState(() {
                                          _controller.reorderExampleCardItem(oldIndex, newIndex);
                                        });
                                      },
                                      children: getExampleCards(),
                                    ),
                                  )),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline_rounded),
                                color: Colors.purple,
                                onPressed: () {
                                  setState(() {
                                    _controller.examples.add(KoreanBiteExample(_controller.examples.length));
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(30),
                        child: ElevatedButton(
                          onPressed: () {
                            Database().runKoreanBiteBatch(koreanBite: koreanBite);
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: Text(
                              '저장',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
