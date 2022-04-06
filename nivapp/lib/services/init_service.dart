import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';

class InitService {
  Future<void> init() =>
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}
