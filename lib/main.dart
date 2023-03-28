import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/common/database.dart';
import 'package:podo_admin/screens/lesson/lesson_card_main.dart';
import 'package:podo_admin/screens/lesson/lesson_state_manager.dart';
import 'package:podo_admin/screens/main_frame.dart';
import 'package:podo_admin/screens/reading/reading_detail.dart';
import 'package:podo_admin/screens/value/color_schemes.g.dart';
import 'firebase_options.dart';


void main() async {
  print('Main is starting');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('Init firebase!');
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        //useMaterial3: true,
        colorScheme: lightColorScheme,
      ),
      home: const ReadingDetail(),
    );
  }

  //todo: 삭제할 것
  goToLessonCard() async {
    String sampleTitleId = '6cd5ea6c-faa4-4c49-866b-acacbd81116f';
    Get.find<LessonStateManager>().cards = await Database()
        .getDocumentsFromDb(collection: 'LessonTitles/$sampleTitleId/LessonCards', orderBy: 'orderId');

  }
}
