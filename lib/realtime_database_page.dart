/// Flutter
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Firebase
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Other Page
import 'package:counter_firebase/main.dart';

class RealtimeDatabasePage extends ConsumerStatefulWidget {
  const RealtimeDatabasePage({Key? key}) : super(key: key);

  @override
  RealtimeDatabasePageState createState() => RealtimeDatabasePageState();
}

class RealtimeDatabasePageState extends ConsumerState<RealtimeDatabasePage> {
  @override
  void initState() {
    super.initState();

    /// Realtime Databaseの数値を読取
    RealtimeDatabaseService().read(ref);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Realtime Databaseカウンター'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '${ref.watch(counterProvider)}',
              style: Theme.of(context).textTheme.headline4,
            ),

            /// カウントをリセットし、Realtime Databaseからも削除する
            TextButton(
                onPressed: () {
                  ref.watch(counterProvider.notifier).state = 0;
                  RealtimeDatabaseService().remove();
                },
                child: const Text('Reset')),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(counterProvider.notifier).increment();
          RealtimeDatabaseService().write(ref);
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Realtime Databaseの設定
class RealtimeDatabaseService {
  /// UserIDの取得
  final userID = FirebaseAuth.instance.currentUser?.uid ?? '';

  /// Realtime Databaseのデータベース定義
  DatabaseReference dbRef = FirebaseDatabase.instance.ref('users');

  /// Realtime Databaseへのデータ更新
  void write(WidgetRef ref) async {
    try {
      await dbRef.update({
        '$userID/count': ref.read(counterProvider),
      });
    } catch (e) {
      print('Error : $e');
    }
  }

  /// Realtime Databaseのデータ取得
  void read(WidgetRef ref) async {
    try {
      final snapshot = await dbRef.child(userID).get();
      if (snapshot.exists) {
        ref.read(counterProvider.notifier).state =
            snapshot.child('count').value as int;
      }
    } catch (e) {
      print('Error : $e');
    }
  }

  /// Realtime Databaseのデータ削除
  void remove() async {
    try {
      await dbRef.child(userID).remove();
    } catch (e) {
      print('Error : $e');
    }
  }
}
