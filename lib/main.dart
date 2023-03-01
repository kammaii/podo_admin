import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/screens/main_frame.dart';
import 'package:podo_admin/screens/value/color_schemes.g.dart';

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
      home: const MainFrame(),
    );
  }
}
