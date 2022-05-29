/// Flutter
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Firebase関係のインポート
import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Other Page
import 'package:counter_firebase/main.dart';

class RemoteConfigPage extends ConsumerStatefulWidget {
  const RemoteConfigPage({Key? key}) : super(key: key);

  @override
  RemoteConfigPageState createState() => RemoteConfigPageState();
}

class RemoteConfigPageState extends ConsumerState<RemoteConfigPage> {
  @override
  void initState() {
    super.initState();

    /// Firebase Remote Configの初期化
    FirebaseRemoteConfigService().initRemoteConfig();
  }

  @override
  Widget build(BuildContext context) {
    final counter = ref.watch(counterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Homepage'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            /// Remote Configのデータ取得
            Text(FirebaseRemoteConfig.instance.getString("example_param")),
            Text(
              '$counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(counterProvider.notifier).increment();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Firebase Remote Configの初期設定
class FirebaseRemoteConfigService {
  void initRemoteConfig() async {
    /// インスタンスの作成
    final remoteConfig = FirebaseRemoteConfig.instance;

    /// シングルトンオブジェクトの取得
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(minutes: 5),
    ));

    /// アプリ内デフォルトパラメータ値の設定
    await remoteConfig.setDefaults(const {
      "example_param": "Hello, world!",
    });

    /// 値をフェッチ
    await remoteConfig.fetchAndActivate();
  }
}
