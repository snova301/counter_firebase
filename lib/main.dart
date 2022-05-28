/// Flutter関係のインポート
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Firebase関係のインポート
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

/// 他ページのインポート
import 'package:counter_firebase/normal_counter_page.dart';

/// メイン
void main() async {
  /// Firebaseの初期化
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// ホーム画面
class MyHomePage extends ConsumerWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Homepage'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: <Widget>[
          _PagePushButton(context, 'ノーマルカウンター', const NormalCounterPage()),
        ],
      ),
    );
  }
}

/// ページ遷移ボタン
class _PagePushButton extends ElevatedButton {
  _PagePushButton(BuildContext context, String buttonTitle, pagename)
      : super(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Text(buttonTitle),
          ),
          onPressed: () {
            AnalyticsService().logPage(buttonTitle);
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => pagename));
          },
        );
}

/// Analyticsの実装
class AnalyticsService {
  /// ページ遷移のログ
  Future<void> logPage(String screenName) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'firebase_screen': screenName,
      },
    );
  }
}
