import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/screens/login.dart';
import 'package:podo_admin/screens/main_frame.dart';
import 'package:podo_admin/screens/value/color_schemes.g.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:responsive_framework/responsive_framework.dart';



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
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is null');
        Get.to(Login());
      } else {
        print('User is signed in!');
        Get.to(const MainFrame());
      }
    });
    return GetMaterialApp(
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: [
          const Breakpoint(start: 0, end: 450, name: MOBILE),
          const Breakpoint(start: 451, end: 800, name: TABLET),
          const Breakpoint(start: 801, end: 1920, name: DESKTOP),
        ]
      ),
      title: 'Podo Korean Console',
      theme: ThemeData(
        useMaterial3: false,
        colorScheme: lightColorScheme,
      ),
      home: Login(),
    );
  }
}
