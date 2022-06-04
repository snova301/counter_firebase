/// Flutter関係のインポート
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

/// Firebase関係のインポート
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:counter_firebase/cloud_storage.dart';
import 'package:counter_firebase/firestore_page.dart';
import 'package:counter_firebase/realtime_database_page.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

/// 他ページのインポート
import 'package:counter_firebase/normal_counter_page.dart';
import 'package:counter_firebase/crash_page.dart';
import 'package:counter_firebase/auth_page.dart';
import 'package:counter_firebase/remote_config_page.dart';
import 'package:counter_firebase/ml_page.dart';
import 'package:counter_firebase/cloud_functions_page.dart';

/// プラットフォームの確認
final isAndroid =
    defaultTargetPlatform == TargetPlatform.android ? true : false;
final isIOS = defaultTargetPlatform == TargetPlatform.iOS ? true : false;

/// FCMバックグランドメッセージの設定
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

/// メイン
void main() async {
  /// クラッシュハンドラ
  runZonedGuarded<Future<void>>(() async {
    /// Firebaseの初期化
    WidgetsFlutterBinding.ensureInitialized();

    /// FCMのバックグランドメッセージを表示
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await Firebase.initializeApp(
      name: isAndroid || isIOS ? 'counterFirebase' : null,
      options: DefaultFirebaseOptions.currentPlatform,
    );

    /// クラッシュハンドラ(Flutterフレームワーク内でスローされたすべてのエラー)
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    /// Cloud Functionsのローカルエミュレータ設定
    // FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);

    /// App Check
    // await FirebaseAppCheck.instance.activate(
    //     // webRecaptchaSiteKey: 'recaptcha-v3-site-key',
    //     );

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
class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends ConsumerState<MyHomePage> {
  @override
  void initState() {
    super.initState();

    /// FCMのパーミッション設定
    FirebaseMessagingService().setting();

    /// FCMのトークン表示(テスト用)
    FirebaseMessagingService().fcmGetToken();

    /// Firebase ID取得(テスト用)
    FirebaseInAppMessagingService().getFID();
  }

  @override
  Widget build(BuildContext context) {
    /// ログイン状態の確認
    FirebaseAuth.instance.authStateChanges().listen(
      (User? user) {
        if (user == null) {
          ref.watch(userEmailProvider.state).state = 'ログインしていません';
        } else {
          ref.watch(userEmailProvider.state).state = user.email!;
        }
      },
    );

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

          /// 各ページへの遷移(認証不要)
          _PagePushButton(
              context, 'ノーマルカウンター', const NormalCounterPage(), Colors.blue),
          _PagePushButton(context, 'クラッシュページ', const CrashPage(), Colors.blue),
          _PagePushButton(context, 'Remote Configカウンター',
              const RemoteConfigPage(), Colors.blue),
          _PagePushButton(context, '機械学習ページ', const MLPage(), Colors.blue),

          /// 認証ページへ遷移
          _PagePushButton(context, '認証ページ', const AuthPage(), Colors.red),

          /// 各ページへの遷移(認証後利用可能)
          /// 認証されていなかったらボタンを押せない状態にする
          FirebaseAuth.instance.currentUser?.uid != null
              ? _PagePushButton(context, 'Firestoreカウンター',
                  const FirestorePage(), Colors.green)
              : Container(
                  alignment: Alignment.center,
                  child: const Text('Firestoreカウンターを開くためには認証してください。'),
                ),
          FirebaseAuth.instance.currentUser?.uid != null
              ? _PagePushButton(context, 'Realtime Databaseカウンター',
                  const RealtimeDatabasePage(), Colors.green)
              : Container(
                  alignment: Alignment.center,
                  child: const Text('Realtime Databaseカウンターを開くためには認証してください。'),
                ),
          FirebaseAuth.instance.currentUser?.uid != null
              ? _PagePushButton(context, 'Cloud Storageページ',
                  const CloudStoragePage(), Colors.green)
              : Container(
                  alignment: Alignment.center,
                  child: const Text('Cloud Storageページを開くためには認証してください。'),
                ),
          FirebaseAuth.instance.currentUser?.uid != null
              ? _PagePushButton(context, 'Cloud Functionsページ',
                  const CloudFunctionsPage(), Colors.green)
              : Container(
                  alignment: Alignment.center,
                  child: const Text('Cloud Functionsページを開くためには認証してください。'),
                ),
        ],
      ),
    );
  }
}

/// ページ遷移ボタン
class _PagePushButton extends Container {
  _PagePushButton(
      BuildContext context, String buttonTitle, pagename, Color bgColor)
      : super(
          padding: const EdgeInsets.all(10),
          child: ElevatedButton(
            onPressed: () {
              AnalyticsService().logPage(buttonTitle);
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => pagename));
            },
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(bgColor)),
            child: Text(buttonTitle),
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

/// Firebase Cloud Messageの設定
class FirebaseMessagingService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  /// webとiOS向け設定
  void setting() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }

  void fcmGetToken() async {
    /// モバイル向け
    if (isAndroid || isIOS) {
      final fcmToken = await messaging.getToken();
      print(fcmToken);
    }
    // web向け
    else {
      final fcmToken = await messaging.getToken(
          vapidKey: FirebaseOptionMessaging().webPushKeyPair);
      print('web : $fcmToken');
    }
  }
}

class FirebaseInAppMessagingService {
  void getFID() async {
    String id = await FirebaseInstallations.instance.getId();
    print('id : $id');
  }
}
