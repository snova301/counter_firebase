/// Flutter
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

/// Other Page
import 'package:counter_firebase/normal_counter_page.dart';

/// メイン
void main() async {
  /// Firebaseの初期化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /// runApp w/ Riverpod
  runApp(const ProviderScope(child: MyApp()));
}

/// Providerの初期化
final counterProvider = StateNotifierProvider<Counter, int>((ref) {
  return Counter();
});

class Counter extends StateNotifier<int> {
  Counter() : super(0);

  /// カウントアップ
  void increment() => state++;
}

/// MaterialAppの設定
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Counter Firebase',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Homepage'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: <Widget>[
          ElevatedButton(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: const Text('ノーマルカウンター'),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NormalCounterPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
