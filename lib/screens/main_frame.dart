import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/screens/dashboard/dashboard_main.dart';
import 'package:podo_admin/screens/feedback/feedback_main.dart';
import 'package:podo_admin/screens/korean_bites/korean_bite_state_manager.dart';
import 'package:podo_admin/screens/korean_bites/korean_bite_title_main.dart';
import 'package:podo_admin/screens/lesson/lesson_course_main.dart';
import 'package:podo_admin/screens/loading_controller.dart';
import 'package:podo_admin/screens/podo_message/podo_message_main.dart';
import 'package:podo_admin/screens/podo_words/topics_main.dart';
import 'package:podo_admin/screens/reading/reading_state_manager.dart';
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
    FeedbackMain(),
    const KoreanBiteTitleMain(),
    const TopicsMain(),
    UserMain(),
    const DashboardMain(),
    PodoMessageMain(),
    LessonCourseMain(),
    ReadingTitleMain(),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Get.put(LoadingController());
    Get.put(ReadingStateManager());
    Get.put(KoreanBiteStateManager());
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
                    icon: Icon(Icons.feedback_outlined),
                    selectedIcon: Icon(Icons.feedback),
                    label: Text('피드백'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.cookie_outlined),
                    selectedIcon: Icon(Icons.cookie),
                    label: Text('Korean Bites'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.outlined_flag_sharp),
                    selectedIcon: Icon(Icons.flag_sharp),
                    label: Text('Podo Words'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.people_outline),
                    selectedIcon: Icon(Icons.people_rounded),
                    label: Text('유저'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: Text('대시보드'),
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
            child: const Stack(
              children: [
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
