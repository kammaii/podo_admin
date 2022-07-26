import 'package:flutter/material.dart';
import 'package:podo_admin/screens/lesson/lesson.dart';
import 'package:podo_admin/screens/notice/notice.dart';
import 'package:podo_admin/screens/request/request.dart';
import 'package:podo_admin/screens/user/user.dart';

class MainFrame extends StatefulWidget {
  const MainFrame({Key? key}) : super(key: key);

  @override
  State<MainFrame> createState() => _MainFrameState();
}

class _MainFrameState extends State<MainFrame> {
  final List<Widget> _buildScreens = [
    Lesson(),
    const Request(),
    const User(),
    const Notice(),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            labelType: NavigationRailLabelType.selected,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.task_outlined),
                selectedIcon: Icon(Icons.task_rounded),
                label: Text('요청'),
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
    );
  }
}
