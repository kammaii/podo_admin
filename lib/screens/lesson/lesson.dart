import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/screens/lesson/lesson_state_manager.dart';
import 'package:podo_admin/screens/value/my_strings.dart';

class Lesson extends StatelessWidget {
  Lesson({Key? key}) : super(key: key);

  final LessonStateManager _controller = Get.put(LessonStateManager());

  Widget getRadioButton(String title) {
    return SizedBox(
      width: 150,
      child: ListTile(
        title: Text(title),
        leading: Radio(
          value: title,
          groupValue: _controller.radioValue,
          onChanged: (String? value) {
            _controller.radioValue = value!;
            _controller.update();
          },
        ),
      ),
    );
  }

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
                            const Expanded(
                              child: SizedBox(
                                width: 300,
                                child: TextField(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: '레슨 타이틀',
                                  ),
                                  autofocus: true,
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
                          child: const TextField(
                            decoration: InputDecoration(
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
                    onPressed: () {},
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
        title: const Text('레슨'),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GetBuilder<LessonStateManager>(
            builder: (controller) {
              return Row(
                children: [
                  getRadioButton(MyStrings.hangul),
                  getRadioButton(MyStrings.basic),
                  getRadioButton(MyStrings.intermediate),
                  getRadioButton(MyStrings.advanced),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
