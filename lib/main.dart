import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_admin/screens/login.dart';
import 'package:podo_admin/screens/main_frame.dart';
import 'package:podo_admin/screens/value/color_schemes.g.dart';
import 'firebase_options.dart' as podo_korean_options;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'podo_words_firebase_options.dart' as podo_words_options;


void main() async {
  print('Main is starting');
  WidgetsFlutterBinding.ensureInitialized();

  // Podo Korean 용 firebase
  await Firebase.initializeApp(
    options: podo_korean_options.DefaultFirebaseOptions.currentPlatform,
  );
  // Podo Words 용 firebase
  await Firebase.initializeApp(
    name: 'podoWords',
    options: podo_words_options.DefaultFirebaseOptions.currentPlatform,
  );
  print('Init firebase!');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      home: const AuthWrapper(),
    );
  }
}

// 이 위젯을 MaterialApp의 home으로 설정합니다.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. 첫 번째(기본) 프로젝트의 로그인 상태를 감지합니다.
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, primarySnapshot) {
        // 로딩 중일 때
        if (primarySnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // 1. 기본 앱에 로그인 되어 있다면
        if (primarySnapshot.hasData) {
          // 2. 두 번째('podoWords') 프로젝트의 로그인 상태를 감지합니다.
          return StreamBuilder<User?>(
            stream: FirebaseAuth.instanceFor(app: Firebase.app('podoWords')).authStateChanges(),
            builder: (context, secondarySnapshot) {
              if (secondarySnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              // 2. 두 번째 앱에도 로그인 되어 있다면
              if (secondarySnapshot.hasData) {
                // ✅ 양쪽 모두 로그인 성공! MainFrame으로 이동
                print('Both users are signed in!');
                return const MainFrame();
              }

              // ❌ 한쪽만 로그인된 비정상 상태. 다시 로그인 화면으로 보냅니다.
              print('Primary user is signed in, but secondary is not.');
              return Login();
            },
          );
        }

        // ❌ 기본 앱이 로그인되지 않았다면 로그인 화면으로 보냅니다.
        print('Primary user is not signed in.');
        return Login();
      },
    );
  }
}