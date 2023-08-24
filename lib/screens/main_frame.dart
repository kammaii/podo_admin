import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/screens/lesson/lesson_course_main.dart';
import 'package:podo_admin/screens/loading_controller.dart';
import 'package:podo_admin/screens/podo_message/podo_message_main.dart';
import 'package:podo_admin/screens/reading/reading_title_main.dart';
import 'package:podo_admin/screens/user/user_main.dart';
import 'package:podo_admin/screens/writing/writing_main.dart';

class MainFrame extends StatefulWidget {
  const MainFrame({Key? key}) : super(key: key);

  @override
  State<MainFrame> createState() => _MainFrameState();
}

class _MainFrameState extends State<MainFrame> {
  final List<Widget> _buildScreens = [
    WritingMain(),
    PodoMessageMain(),
    LessonCourseMain(),
    ReadingTitleMain(),
    UserMain(),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Get.put(LoadingController());

    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              NavigationRail(
                selectedLabelTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                minWidth: 100,
                labelType: NavigationRailLabelType.all,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.message_outlined),
                    selectedIcon: Icon(Icons.message_rounded),
                    label: Text('교정'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.cloud_outlined),
                    selectedIcon: Icon(Icons.cloud),
                    label: Text('포도메시지'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.play_lesson_outlined),
                    selectedIcon: Icon(Icons.play_lesson),
                    label: Text('레슨'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.menu_book_outlined),
                    selectedIcon: Icon(Icons.menu_book),
                    label: Text('읽기'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.people_outline),
                    selectedIcon: Icon(Icons.people_rounded),
                    label: Text('유저'),
                  ),
                ],
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
              const VerticalDivider(
                thickness: 1,
                width: 1,
              ),
              Expanded(
                child: _buildScreens[_selectedIndex],
              ),
            ],
          ),
          Obx(() => Offstage(
            offstage: !LoadingController.to.isLoading,
            child: Stack(
              children: const [
                Opacity(opacity: 0.5, child: ModalBarrier(dismissible: false, color: Colors.black)),
                Center(
                  child: CircularProgressIndicator(),
                )
              ],
            ),
          ))
        ],
      ),
    );
  }
}
