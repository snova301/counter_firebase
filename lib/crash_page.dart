/// Flutter
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CrashPage extends ConsumerWidget {
  const CrashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('クラッシュページ'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: <Widget>[
          TextButton(
            onPressed: () => throw Exception(),
            child: const Text("Throw Test Exception"),
          ),
        ],
      ),
    );
  }
}
