import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:podo_admin/common/my_textfield.dart';

class Login extends StatelessWidget {
  Login({Key? key}) : super(key: key);

  final String adminEmail = 'danny@podokorean.com';
  late String email;
  late String pass;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyTextField().getTextField(
                  autoFocus: true,
                  label: '이메일',
                  maxLines: 1,
                  fn: (value) {
                    email = value;
                  }),
              const SizedBox(height: 20),
              TextField(
                controller: TextEditingController(),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '비밀번호',
                ),
                obscureText: true,
                onChanged: (value) {
                  pass = value;
                },
                maxLines: 1,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () async {
                    // if (email == adminEmail) {
                    //   await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: pass);
                    //   FirebaseAuth.instanceFor(app: Firebase.app('podoWords')).signInWithEmailAndPassword(email: email, password: pass);
                    // }
                    await FirebaseAuth.instance.signInWithEmailAndPassword(email: 'danny@podokorean.com', password: '123123');
                    FirebaseAuth.instanceFor(app: Firebase.app('podoWords')).signInWithEmailAndPassword(email: 'danny@podokorean.com', password: '123123');
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('입력', textScaleFactor: 1.2),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
