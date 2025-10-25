import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: "AIzaSyCdU-IrwrDgedCarsSjk4OnGQaw_s2iF1Y",
      authDomain: "tailoringapp-c768d.firebaseapp.com",
      projectId: "tailoringapp-c768d",
      storageBucket: "tailoringapp-c768d.firebasestorage.app",
      messagingSenderId: "270975220033",
      appId: "1:270975220033:web:0ea07ed752f844542749c0",
      measurementId: "G-4LP3KFSN9S"
    );
  }

  // Firebase hosting site details
  static const String hostingSite = "el-tailor";
  static const String projectName = "Tailoring Shop Web";
  static const String appNickname = "Tailoring Shop Web";
}
