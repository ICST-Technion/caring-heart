import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? name;
  String? uid;
  String? userEmail;
  bool remember = false;

  Future<bool?> isUserRemembered() async {
    bool? result = await SharedPreferences.getInstance().then((value) => value.getBool('auth'));
    remember = true;
    return result;
  }

  Future<String?> signInWithEmailPassword(String email, String password) async {
    User? user;

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = userCredential.user;

      if (user != null) {
        uid = user.uid;
        userEmail = user.email;

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('auth', true);
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

  Future<String> signOut() async {
    await _auth.signOut();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('auth', false);

    uid = null;
    userEmail = null;
    remember = false;

    return 'User signed out';
  }



}