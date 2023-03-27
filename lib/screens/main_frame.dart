import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/screens/lesson/lesson_main.dart';
import 'package:podo_admin/screens/loading_controller.dart';
import 'package:podo_admin/screens/notice/notice_main.dart';
import 'package:podo_admin/screens/question/question_main.dart';
import 'package:podo_admin/screens/reading/reading_main.dart';
import 'package:podo_admin/screens/test/testdb.dart';
import 'package:podo_admin/screens/user/user_main.dart';
import 'package:podo_admin/screens/writing/writing_main.dart';

class MainFrame extends StatefulWidget {
  const MainFrame({Key? key}) : super(key: key);

  @override
  State<MainFrame> createState() => _MainFrameState();
}

class _MainFrameState extends State<MainFrame> {
  final List<Widget> _buildScreens = [
    ReadingMain(),

    LessonMain(),
    WritingMain(),
    QuestionMain(),
    UserMain(),
    NoticeMain(),
    const TestDB(),
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
                    icon: Icon(Icons.question_mark_outlined),
                    selectedIcon: Icon(Icons.question_mark_rounded),
                    label: Text('질문'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.people_outline),
                    selectedIcon: Icon(Icons.people_rounded),
                    label: Text('유저'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.circle_notifications_outlined),
                    selectedIcon: Icon(Icons.circle_notifications),
                    label: Text('알림'),
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
                    icon: Icon(Icons.balance_outlined),
                    selectedIcon: Icon(Icons.balance_rounded),
                    label: Text('샘플만들기'),
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
