/// Flutter関係のインポート
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

/// Firebase関係のインポート
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 他ページのインポート
import 'package:counter_firebase/normal_counter_page.dart';
import 'package:counter_firebase/crash_page.dart';
import 'package:counter_firebase/auth_page.dart';
import 'package:counter_firebase/remote_config_page.dart';

/// メイン
void main() async {
  /// クラッシュハンドラ
  runZonedGuarded<Future<void>>(() async {
    /// Firebaseの初期化
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    /// クラッシュハンドラ(Flutterフレームワーク内でスローされたすべてのエラー)
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    /// runApp w/ Riverpod
    runApp(const ProviderScope(child: MyApp()));
  },

      /// クラッシュハンドラ(Flutterフレームワーク内でキャッチされないエラー)
      (error, stack) =>
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true));
}

/// Providerの初期化
/// カウンター用のプロバイダー
final counterProvider = StateNotifierProvider.autoDispose<Counter, int>((ref) {
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
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        ref.watch(userEmailProvider.state).state = 'ログインしていません';
      } else {
        ref.watch(userEmailProvider.state).state = user.email!;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Homepage'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: <Widget>[
          /// ユーザ情報の表示
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person),
              Text(ref.watch(userEmailProvider)),
            ],
          ),

          /// 各ページへの遷移
          _PagePushButton(context, 'ノーマルカウンター', const NormalCounterPage()),
          _PagePushButton(context, 'クラッシュページ', const CrashPage()),
          _PagePushButton(
              context, 'Remote Configカウンター', const RemoteConfigPage()),
          _PagePushButton(context, '認証ページ', const AuthPage()),
        ],
      ),
    );
  }
}

/// ページ遷移ボタン
class _PagePushButton extends Container {
  _PagePushButton(BuildContext context, String buttonTitle, pagename)
      : super(
          padding: const EdgeInsets.all(10),
          child: ElevatedButton(
            child: Text(buttonTitle),
            onPressed: () {
              AnalyticsService().logPage(buttonTitle);
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => pagename));
            },
          ),
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
