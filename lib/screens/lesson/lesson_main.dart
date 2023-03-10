import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/my_radio_btn.dart';
import 'package:podo_admin/screens/lesson/lesson_state_manager.dart';
import 'package:podo_admin/screens/lesson/lesson_title.dart';

class LessonMain extends StatelessWidget {
  LessonMain({Key? key}) : super(key: key);

  final LessonStateManager _controller = Get.put(LessonStateManager());
  final TextEditingController _textEditingControllerTitle = TextEditingController();
  final TextEditingController _textEditingControllerCategory = TextEditingController();
  final TextEditingController _textEditingControllerVideoLink = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('레슨 만들기'),
                content: GetBuilder<LessonStateManager>(
                  builder: (controller) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 300,
                              child: TextField(
                                controller: _textEditingControllerTitle,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: '레슨 타이틀',
                                ),
                                autofocus: true,
                              ),
                            ),
                            const SizedBox(width: 20),
                            SizedBox(
                              width: 300,
                              child: TextField(
                                controller: _textEditingControllerCategory,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: '카테고리',
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Column(
                              children: [
                                const Text('비디오레슨'),
                                Checkbox(
                                  value: controller.isVideoChecked,
                                  onChanged: (bool? value) {
                                    controller.setVideoChecked(value!);
                                  },
                                  activeColor: Theme.of(context).colorScheme.primary,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        AnimatedOpacity(
                          opacity: controller.isVideoChecked ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 500),
                          child: TextField(
                            controller: _textEditingControllerVideoLink,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: '비디오 링크',
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
                      String title = _textEditingControllerTitle.text;
                      String category = _textEditingControllerCategory.text;
                      String link = _textEditingControllerVideoLink.text;

                      LessonTitle lessonTitle = LessonTitle(
                        lessonGroup: _controller.lessonGroup,
                        orderId: SampleLessonTitles().getTitles().length,
                        //todo: 실재 DB 데이터로 수정
                        category: category,
                        title: title,
                        isVideo: _controller.isVideoChecked,
                        videoLink: _controller.isVideoChecked ? link : '',
                        isPublished: false,
                      );

                      //Get.to(LessonDetail(lessonTitle: lessonTitle));

                      _textEditingControllerTitle.dispose();
                      _textEditingControllerCategory.dispose();
                      _textEditingControllerVideoLink.dispose();
                    },
                    child: const Text('만들기'),
                  ),
                ],
              );
            },
          );
        },
        icon: const Icon(Icons.add_circle_outline_rounded),
        label: const Text('레슨만들기'),
      ),
      appBar: AppBar(
        title: const Text('레슨 주제'),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GetBuilder<LessonStateManager>(
            builder: (controller) {
              return Row(
                children: [
                  MyRadioBtn().getRadioButton(
                      context: context,
                      title: '한글',
                      radio: _controller.lessonGroup,
                      f: _controller.changeLessonGroupRadio()),
                  MyRadioBtn().getRadioButton(
                      context: context,
                      title: '기초',
                      radio: _controller.lessonGroup,
                      f: _controller.changeLessonGroupRadio()),
                  MyRadioBtn().getRadioButton(
                      context: context,
                      title: '여행',
                      radio: _controller.lessonGroup,
                      f: _controller.changeLessonGroupRadio()),
                  MyRadioBtn().getRadioButton(
                      context: context,
                      title: '음식',
                      radio: _controller.lessonGroup,
                      f: _controller.changeLessonGroupRadio()),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class SampleLessonTitles {
  List<String> titles = [];

  List<String> getTitles() {
    return titles;
  }
}
