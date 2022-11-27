import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/items/lesson_title.dart';
import 'package:podo_admin/screens/lesson/lesson_detail.dart';
import 'package:podo_admin/screens/lesson/lesson_main.dart';
import 'package:podo_admin/screens/message/message_detail.dart';
import 'package:podo_admin/screens/message/message_finder.dart';
import 'package:podo_admin/screens/user/user_main.dart';
import 'package:podo_admin/screens/value/color_schemes.g.dart';
import 'package:podo_admin/screens/main_frame.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() {
  print('Main is starting');
  initFirebase();
  print('Init firebase!');
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

void initFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
