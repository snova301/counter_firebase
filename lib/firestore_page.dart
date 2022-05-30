/// Flutter
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Other Page
import 'package:counter_firebase/main.dart';

class FirestorePage extends ConsumerStatefulWidget {
  const FirestorePage({Key? key}) : super(key: key);

  @override
  FirestorePageState createState() => FirestorePageState();
}

class FirestorePageState extends ConsumerState<FirestorePage> {
  @override
  void initState() {
    super.initState();

    /// Firestoreの数値を読取
    FirestoreService().get(ref);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestoreカウンター'),
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

            /// カウントをリセットし、Firestoreからも削除する
            TextButton(
                onPressed: () {
                  ref.watch(counterProvider.notifier).state = 0;
                  FirestoreService().delete();
                },
                child: const Text('Reset')),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(counterProvider.notifier).increment();
          FirestoreService().add(ref);
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Firestoreの設定
class FirestoreService {
  /// firestoreのデータベース定義
  final db = FirebaseFirestore.instance;

  /// UserIDの取得
  final userID = FirebaseAuth.instance.currentUser?.uid ?? 'test';

  /// firestoreへのデータ更新
  void add(WidgetRef ref) {
    /// Map<String, dynamic>に変換
    final Map<String, dynamic> counterMap = {
      'count': ref.read(counterProvider),
    };

    /// Firestoreへデータ追加
    try {
      db.collection('users').doc(userID).set(counterMap);
    } catch (e) {
      print('Error : $e');
    }
  }

  /// firestoreのデータ取得
  void get(WidgetRef ref) async {
    try {
      await db.collection('users').doc(userID).get().then(
        (event) {
          ref.read(counterProvider.notifier).state = event.get('count');
        },
      );
    } catch (e) {
      print('Error : $e');
    }
  }

  /// firestoreのデータ削除
  void delete() async {
    try {
      db.collection('users').doc(userID).delete().then((doc) => null);
    } catch (e) {
      print('Error : $e');
    }
  }
}
