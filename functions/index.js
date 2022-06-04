const functions = require("firebase-functions");

const admin = require('firebase-admin');
admin.initializeApp({credential: admin.credential.applicationDefault(),});

exports.functionsTest = functions.https.onCall(async(data, context) => {
  /// App Checkの実施
  if (context.app == undefined) {
        throw new functions.https.HttpsError(
            'failed-precondition',
            'The function must be called from an App Check verified app.')
      }

  /// 数値読み取り
  const firstNumber = data.firstNumber;
  const secondNumber = data.secondNumber;

  /// 計算実行
  const addNumber = firstNumber + secondNumber;

  /// ついでに、UIDも呼び出せるか実験
  const contextUid = context.auth.uid;

  return { addNumber:addNumber,  contextUid:contextUid }
});
