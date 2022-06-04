/// Flutter
import 'package:flutter/material.dart';

/// Firebase
import 'package:cloud_functions/cloud_functions.dart';

class CloudFunctionsPage extends StatefulWidget {
  const CloudFunctionsPage({Key? key}) : super(key: key);

  @override
  CloudFunctionsPageState createState() => CloudFunctionsPageState();
}

class CloudFunctionsPageState extends State<CloudFunctionsPage> {
  /// 初期化
  int _number = 0;

  /// Cloud Functionsの実行
  void addNumber() async {
    try {
      /// 数を
      final result = await FirebaseFunctions.instance
          .httpsCallable('functionsTest')
          .call({'firstNumber': _number, 'secondNumber': 1});
      _number = result.data['addNumber'];
      print(result.data['contextUid']);
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Functionsページ'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_number',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            addNumber();
          });
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
