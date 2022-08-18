import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/items/lesson_title.dart';
import 'package:podo_admin/screens/lesson/lesson_detail.dart';
import 'package:podo_admin/screens/lesson/lesson_main.dart';
import 'package:podo_admin/screens/value/color_schemes.g.dart';
import 'package:podo_admin/screens/main_frame.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme
      ),
      home: LessonDetail(),
    );
  }
}
