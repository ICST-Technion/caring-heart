import 'package:firebase_auth/firebase_auth.dart';
import 'package:nivapp/main.dart';
import 'package:nivapp/services/auth_service_i.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyAuth implements AuthServiceI {
  final FirebaseAuth auth;
  final Future<SharedPreferences> sharedPreferences;
  String? name;
  String? uid;
  String? userEmail;
  bool remember = false;
  MyAuth({required this.auth, required this.sharedPreferences});

  @override
  Future<bool> isUserRemembered() async {
    bool? result =
        await sharedPreferences.then((value) => value.getBool('auth'));
    remember = true;
    return result != null && result;
  }

  @override
  Future<String?> signInWithEmailPassword(String email, String password) async {
    User? user;

    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = userCredential.user;

      if (user != null) {
        uid = user.uid;
        userEmail = user.email;

        (await sharedPreferences).setBool('auth', true);
        remember = true;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return ('המשתמש לא נמצא במערכת');
      } else if (e.code == 'wrong-password') {
        return ('הסיסמה שגויה');
      }
    }

    return null;
  }

  @override
  Future<String> signOut() async {
    await auth.signOut();

    (await sharedPreferences).setBool('auth', false);

    uid = null;
    userEmail = null;
    remember = false;

    return 'User signed out';
  }
}
