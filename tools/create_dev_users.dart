import '../lib/firebase_options.dart';
import '../lib/services/dev_setup_service.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Create development users
    await DevSetupService.createDevUsers();
  } catch (e) {
    print('Error: $e');
  }
}
