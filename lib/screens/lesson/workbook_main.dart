import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/common/my_textfield.dart';
import 'package:podo_admin/screens/lesson/lesson_course.dart';
import 'package:podo_admin/screens/lesson/workbook.dart';
import 'package:uuid/uuid.dart';

class WorkbookMain extends StatefulWidget {
  const WorkbookMain({Key? key}) : super(key: key);

  @override
  State<WorkbookMain> createState() => _WorkbookMainState();
}

class _WorkbookMainState extends State<WorkbookMain> {
  LessonCourse course = Get.arguments;
  late Workbook workbook;
  bool isLoaded = false;
  final ScrollController scrollController = ScrollController();
  List<bool> hasFreeOptionToggle = [false, true];

  Future uploadImage({required bool isSampleImage}) async {
    final pickedFile = await FilePicker.platform.pickFiles(type: FileType.image);

    if (pickedFile != null) {
      Uint8List? imageBytes = pickedFile.files.single.bytes;
      if (imageBytes != null) {
        String base64Image = base64Encode(imageBytes);
        isSampleImage ? workbook.sampleImages.add(base64Image) : workbook.image = base64Image;
        setState(() {});
      } else {
        print('Failed to read image file.');
      }
    } else {
      print('No image selected.');
    }
  }

  Widget getAudioWidget(List<dynamic> audios) {
    return Column(
      children: List<Widget>.generate(audios.length, (index) {
        List<String> audioNo = audios[index].split('&');
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: audioNo[1]));
                    Get.snackbar('아이디가 클립보드에 저장되었습니다.', audioNo[1], snackPosition: SnackPosition.BOTTOM);
                  },
                  icon: const Icon(Icons.copy, size: 20)),
              const SizedBox(width: 10),
              SizedBox(
                width: 100,
                child: MyTextField().getTextField(
                    controller: TextEditingController(text: audioNo[0]),
                    label: '오디오번호',
                    fn: (String? value) {
                      audios[index] = '${value!}&${audioNo[1]}';
                    }),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MyTextField().getTextField(
                    controller: TextEditingController(text: audioNo[1]),
                    label: '오디오ID',
                    fn: (String? value) {
                      audios[index] = '${audioNo[0]}&${value!}';
                    }),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: () {
                  setState(() {
                    audios.removeAt(index);
                  });
                },
                icon: const Icon(Icons.remove_circle_outlined),
                color: Colors.red,
              )
            ],
          ),
        );
      }),
    );
  }

  Widget getLessonWidget() {
    List<Widget> widget = [];
    for (int i = 0; i < workbook.lessons.length; i++) {
      widget.add(Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                Text('Lesson ${i + 1}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                Expanded(
                  child: MyTextField().getTextField(
                      label: '타이틀',
                      controller: TextEditingController(text: workbook.lessons[i]['title']),
                      fn: (String? value) {
                        workbook.lessons[i]['title'] = value!;
                      }),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MyTextField().getTextField(
                      label: '서브 타이틀',
                      controller: TextEditingController(text: workbook.lessons[i]['subTitle']),
                      fn: (String? value) {
                        workbook.lessons[i]['subTitle'] = value!;
                      }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          getAudioWidget(workbook.lessons[i]['audios']),
          const SizedBox(height: 10),
          IconButton(
              onPressed: () {
                List<String> lastAudio = workbook.lessons[i]['audios'].last.split('&');
                String first = lastAudio[0].split('-')[0];
                String second = lastAudio[0].split('-')[1];
                String newSecond = (int.parse(second) + 1).toString();
                setState(() {
                  workbook.lessons[i]['audios'].add('$first-$newSecond&${const Uuid().v4()}');
                });
              },
              icon: const Icon(CupertinoIcons.plus_circle),
              color: Colors.deepPurple)
        ],
      ));
    }
    return Column(
      children: widget,
    );
  }

  @override
  void initState() {
    super.initState();
    Database().getDocs(collection: 'LessonCourses/${course.id}/Workbooks', orderBy: 'orderId').then((snapshots) {
      if (snapshots.isNotEmpty) {
        workbook = Workbook.fromJson(snapshots[0] as Map<String, dynamic>); //todo: 워크북 여러개 생겼을 때 수정하기
      } else {
        workbook = Workbook();
      }
      hasFreeOptionToggle[0] = workbook.hasFreeOption == true;
      hasFreeOptionToggle[1] = workbook.hasFreeOption == false;

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          isLoaded = true;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoaded
        ? Scaffold(
            appBar: AppBar(
              title: GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: workbook.id));
                    Get.snackbar('아이디가 클립보드에 저장되었습니다.', workbook.id, snackPosition: SnackPosition.BOTTOM);
                  },
                  child: Text('${course.title['en']} 워크북: ${workbook.id}')),
            ),
            body: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          SizedBox(
                            width: 500,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Column(
                                      children: [
                                        workbook.image.isNotEmpty
                                            ? Stack(
                                                children: [
                                                  Image.memory(base64Decode(workbook.image),
                                                      height: 200, width: 200),
                                                  Positioned(
                                                    top: 0,
                                                    right: 0,
                                                    child: IconButton(
                                                      alignment: Alignment.topRight,
                                                      padding: const EdgeInsets.all(0),
                                                      icon: const Icon(Icons.remove_circle_outline_outlined),
                                                      color: Colors.red,
                                                      onPressed: () {
                                                        workbook.image = '';
                                                        setState(() {});
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : const SizedBox(width: 200, height: 200, child: Icon(Icons.error)),
                                        const SizedBox(height: 10),
                                        ElevatedButton(
                                          onPressed: () {
                                            uploadImage(isSampleImage: false);
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                            child: Text('이미지 업로드'),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 30),
                                    Column(
                                      children: [
                                        workbook.sampleImages.isNotEmpty
                                            ? Stack(
                                                children: [
                                                  SizedBox(
                                                    height: 200,
                                                    width: 200,
                                                    child: GridView.builder(
                                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount: 1,
                                                        childAspectRatio: 1,
                                                      ),
                                                      itemCount: workbook.sampleImages.length,
                                                      itemBuilder: (BuildContext context, int index) {
                                                        var bytes = base64.decode(workbook.sampleImages[index]);
                                                        return SizedBox(
                                                          width: 200,
                                                          height: 200,
                                                          child: Image.memory(
                                                            bytes,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 0,
                                                    right: 0,
                                                    child: IconButton(
                                                      alignment: Alignment.topRight,
                                                      padding: const EdgeInsets.all(0),
                                                      icon: const Icon(Icons.remove_circle_outline_outlined),
                                                      color: Colors.red,
                                                      onPressed: () {
                                                        workbook.sampleImages = [];
                                                        setState(() {});
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : const SizedBox(width: 200, height: 200, child: Icon(Icons.error)),
                                        const SizedBox(height: 10),
                                        ElevatedButton(
                                          onPressed: () {
                                            uploadImage(isSampleImage: true);
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                            child: Text('샘플 이미지 업로드'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30),
                                Row(
                                  children: [
                                    const SizedBox(
                                        width: 100,
                                        child: Text('무료옵션',
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ToggleButtons(
                                        isSelected: hasFreeOptionToggle,
                                        onPressed: (int index) {
                                          setState(() {
                                            hasFreeOptionToggle[0] = index == 0;
                                            hasFreeOptionToggle[1] = index == 1;
                                            if (index == 0) {
                                              workbook.hasFreeOption = true;
                                            } else {
                                              workbook.hasFreeOption = false;
                                            }
                                          });
                                        },
                                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                                        children: const [
                                          Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 10), child: Text('있음')),
                                          Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 10), child: Text("없음")),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const SizedBox(
                                        width: 100,
                                        child: Text('워크북타이틀',
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: MyTextField().getTextField(
                                          controller: TextEditingController(text: workbook.title),
                                          fn: (String? value) {
                                            workbook.title = value!;
                                          }),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const SizedBox(
                                        width: 100,
                                        child: Text('스토어 링크',
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: MyTextField().getTextField(
                                          controller: TextEditingController(text: workbook.storeLink),
                                          fn: (String? value) {
                                            workbook.storeLink = value!;
                                          }),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const SizedBox(
                                        width: 100,
                                        child: Text('인앱상품 ID',
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: MyTextField().getTextField(
                                          controller: TextEditingController(text: workbook.productId),
                                          fn: (String? value) {
                                            workbook.productId = value!;
                                          }),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const SizedBox(
                                        width: 100,
                                        child: Text('pdf파일',
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: MyTextField().getTextField(
                                          controller: TextEditingController(text: workbook.pdfFile),
                                          fn: (String? value) {
                                            workbook.pdfFile = value!;
                                          }),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 50),
                          SizedBox(
                            width: 800,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      workbook.lessons.add({
                                        'title': '',
                                        'subTitle': '',
                                        'audios': ['1-1&${const Uuid().v4()}']
                                      });
                                    });
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    child: Text('레슨 추가'),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Expanded(child: SingleChildScrollView(child: getLessonWidget())),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: ElevatedButton(
                            onPressed: () {
                              Database().setDoc(collection: 'LessonCourses/${course.id}/Workbooks', doc: workbook);
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: Text('저장'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )),
          )
        : const Center(child: CircularProgressIndicator());
  }
}
