/// Flutter
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';

/// Firebase
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 画像表示用Provider
final imageStateProvider = StateProvider<Uint8List?>((ref) => null);

class CloudStoragePage extends ConsumerStatefulWidget {
  const CloudStoragePage({Key? key}) : super(key: key);

  @override
  CloudStoragePageState createState() => CloudStoragePageState();
}

class CloudStoragePageState extends ConsumerState<CloudStoragePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Storageページ'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  CloudStorageService().uploadPic();
                },
                child: const Icon(Icons.upload),
              ),
              ElevatedButton(
                onPressed: () {
                  CloudStorageService().downloadPic(ref);
                },
                child: const Icon(Icons.download),
              ),
            ],
          ),
          ref.watch(imageStateProvider) == null
              ? const Text('No Image')
              : Image.memory(ref.watch(imageStateProvider)!),
          TextButton(
            onPressed: () {
              CloudStorageService().deletePic(ref);
            },
            child: const Text('画像をクリア'),
          ),
        ],
      ),
    );
  }
}

/// Realtime Databaseの設定
class CloudStorageService {
  /// UserIDの取得
  final userID = FirebaseAuth.instance.currentUser?.uid ?? '';

  void uploadPic() async {
    try {
      /// 画像を選択
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      File file = File(image!.path);

      /// Firebase Cloud Storageにアップロード
      String uploadName = 'image.png';
      final storageRef =
          FirebaseStorage.instance.ref().child('users/$userID/$uploadName');
      final task = await storageRef.putFile(file);
    } catch (e) {
      print(e);
    }
  }

  /// 画像のダウンロード
  void downloadPic(WidgetRef ref) async {
    try {
      /// 参照の作成
      String downloadName = 'image.png';
      final storageRef =
          FirebaseStorage.instance.ref().child('users/$userID/$downloadName');

      /// 画像をメモリに保存し、Uint8Listへ変換
      const oneMegabyte = 1024 * 1024;
      ref.read(imageStateProvider.state).state =
          await storageRef.getData(oneMegabyte);
    } catch (e) {
      print(e);
    }
  }

  /// 画像の削除
  void deletePic(WidgetRef ref) async {
    /// 参照の作成
    String deleteName = 'image.png';
    final storageRef =
        FirebaseStorage.instance.ref().child('users/$userID/$deleteName');

    /// Cloud Storageから削除
    await storageRef.delete();

    /// メモリから削除
    ref.read(imageStateProvider.state).state = null;
  }
}
