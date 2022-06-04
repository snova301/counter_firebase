/// Flutter
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

/// Firebase
// import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';

/// Providerの初期化
final imageStateProvider = StateProvider<File?>((ref) => null);
final textStateProvider = StateProvider<String?>((ref) => null);

class MLPage extends ConsumerStatefulWidget {
  const MLPage({Key? key}) : super(key: key);

  @override
  MLPageState createState() => MLPageState();
}

class MLPageState extends ConsumerState<MLPage> {
  // final TextRecognizer _textRecognizer = TextRecognizer();
  /// 画像ラベル分類問題の定義
  late ImageLabeler _imageLabeler;
  ImagePicker? _imagePicker;

  /// ImageLabelerの初期化
  @override
  void initState() {
    super.initState();
    _initializeLabeler();
    _imagePicker = ImagePicker();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('画像からラベル分類'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          /// 画像が存在すれば画像を表示
          /// そうでなければ画像アイコンを表示
          ref.watch(imageStateProvider) != null
              ? SizedBox(
                  height: 400,
                  width: 400,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      Image.file(ref.watch(imageStateProvider)!),
                    ],
                  ),
                )
              : const Icon(
                  Icons.image,
                  size: 200,
                ),
          ElevatedButton(
            child: const Text('写真を選択'),
            onPressed: () => _getImage(ImageSource.gallery),
          ),

          Container(
            padding: const EdgeInsets.all(10),
            child: Text(ref.watch(imageStateProvider) == null
                ? ''
                : ref.watch(textStateProvider) ?? ''),
          ),
        ],
      ),
    );
  }

  /// ラベラーの初期化
  void _initializeLabeler() async {
    // uncomment next line if you want to use the default model
    // _imageLabeler = ImageLabeler(options: ImageLabelerOptions());

    // uncomment next lines if you want to use a local model
    // make sure to add tflite model to assets/ml
    // final path = 'assets/ml/lite-model_aiy_vision_classifier_birds_V1_3.tflite';
    // final path = 'assets/ml/object_labeler.tflite';
    // final modelPath = await _getModel(path);
    // final options = LocalLabelerOptions(modelPath: modelPath);
    // _imageLabeler = ImageLabeler(options: options);

    // uncomment next lines if you want to use a remote model
    // make sure to add model to firebase
    // final modelName = 'bird-classifier';
    // final response =
    //     await FirebaseImageLabelerModelManager().downloadModel(modelName);
    // print('Downloaded: $response');
    // final options =
    //     FirebaseLabelerOption(confidenceThreshold: 0.5, modelName: modelName);
    // _imageLabeler = ImageLabeler(options: options);

    // _canProcess = true;

    /// モデルの名前はFirebase MLにアップロードした名前
    const modelname = 'Image';

    /// FirebaseからML kitに学習モデルを読込ませるため、FirebaseImageLabelerModelManagerを使う
    /// 参考 : https://pub.dev/documentation/google_mlkit_image_labeling/latest/
    final bool response =
        await FirebaseImageLabelerModelManager().downloadModel(modelname);
    print(response);

    /// ラベラーのオプションを設定し、読込
    final options = FirebaseLabelerOption(
        confidenceThreshold: 0.5, modelName: modelname, maxCount: 3);
    _imageLabeler = ImageLabeler(options: options);
  }

  /// 画像を選択し推論を実行
  Future _getImage(ImageSource source) async {
    /// 画像選択
    final pickedFile = await _imagePicker?.pickImage(source: source);

    /// 有効な画像が選択できたら推論
    if (pickedFile != null) {
      /// ファイルのパスを取得
      final path = pickedFile.path;
      ref.read(imageStateProvider.state).state = File(path);
      final inputImage = InputImage.fromFilePath(path);

      /// テキスト認識推論実行
      // final recognizedText = await _textRecognizer.processImage(inputImage);

      /// ラベル分類推論実行
      final labels = await _imageLabeler.processImage(inputImage);

      /// ラベルの分類が成功した場合、ラベルのテキストを生成
      if (inputImage.inputImageData?.size != null &&
          inputImage.inputImageData?.imageRotation != null) {
      } else {
        // ref.read(textStateProvider.state).state = recognizedText.text;
        String labelText = '';
        for (final label in labels) {
          labelText += '\nLabel: ${label.label}';
        }
        ref.read(textStateProvider.state).state = labelText;
      }
    }
  }
}

// class FirebaseMLService {
//   Future<void> downloadModel(String modelname) async {
//     await FirebaseModelDownloader.instance
//         .getModel(
//             modelname,
//             FirebaseModelDownloadType.latestModel,
//             FirebaseModelDownloadConditions(
//               iosAllowsCellularAccess: true,
//               iosAllowsBackgroundDownloading: false,
//               androidChargingRequired: false,
//               androidWifiRequired: false,
//               androidDeviceIdleRequired: false,
//             ))
//         .then(
//       (customModel) {
//         // Download complete. Depending on your app, you could enable the ML
//         // feature, or switch from the local model to the remote model, etc.

//         // The CustomModel object contains the local path of the model file,
//         // which you can use to instantiate a TensorFlow Lite interpreter.
//         final localModelPath = customModel.file;
//         print(customModel);
//         print(customModel.name);
//         print(customModel.size);
//         print(localModelPath);
//       },
//     );
//   }
// }
