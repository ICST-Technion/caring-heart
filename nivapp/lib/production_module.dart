import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:nivapp/services/auth_service.dart';
import 'package:nivapp/services/auth_service_i.dart';
import 'package:shared_preferences/shared_preferences.dart';

Injector ProductionModule() {
  final injector = Injector();

  injector.map<FirebaseAuth>((injector) => FirebaseAuth.instance);
  injector.map<Future<SharedPreferences>>(
      (injector) => SharedPreferences.getInstance());
  injector.map<AuthServiceI>(
      (injector) =>
          MyAuth(auth: injector.get(), sharedPreferences: injector.get()),
      isSingleton: true);

  return injector;
}
