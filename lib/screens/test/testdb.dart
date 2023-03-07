import 'package:flutter/material.dart';

class TestDB extends StatelessWidget {
  const TestDB({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          ElevatedButton(
            onPressed: (){

            },
            child: const Text('make question db'),
          ),
        ],
      ),
    );
  }
}
