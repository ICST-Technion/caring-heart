import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:nivapp/services/auth_service.dart';
import 'package:nivapp/services/auth_service_i.dart';
import 'package:nivapp/services/init_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Injector ProductionModule() {
  final injector = Injector();

  injector.map<FirebaseAuth>((injector) => FirebaseAuth.instance);
  injector
      .map<Future<SharedPreferences>>((i) => SharedPreferences.getInstance());
  injector.map<AuthServiceI>(
      (i) => MyAuth(auth: i.get(), sharedPreferences: i.get()),
      isSingleton: true);
  injector.map<InitService>((i) => InitService(), isSingleton: true);

  return injector;
}
