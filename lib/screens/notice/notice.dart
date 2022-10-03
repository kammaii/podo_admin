import 'package:flutter/material.dart';
import 'package:podo_admin/screens/value/my_strings.dart';

class Notice extends StatelessWidget {
  const Notice({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림'),
      ),
    );
  }
}
