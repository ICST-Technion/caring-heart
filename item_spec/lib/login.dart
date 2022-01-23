
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'auth_service.dart';

class Login extends StatefulWidget {
  const Login({Key? key, required this.func}) : super(key: key);

  final Widget Function(MyAuth) func;

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _auth = MyAuth();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _auth.isUserRemembered(),
        builder: (context, AsyncSnapshot<bool?> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (_auth.uid == null &&
                (snapshot.data == null || !snapshot.data!)) {
              return loginForm();
            } else if (snapshot.data != null && snapshot.data!) {
              return widget.func(_auth);
            }
          }
          return const Center(child: CircularProgressIndicator());
        });
  }

  Widget loginForm() {
    return MaterialApp(
      home: Builder(
          builder: (context) {
            return Center(
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: FlutterLogin(
                    theme: LoginTheme(pageColorLight: Colors.lightBlueAccent),
                    onLogin: (LoginData data) =>
                        _auth.signInWithEmailPassword(data.name, data.password),
                    onSubmitAnimationCompleted: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => widget.func(_auth),
                      ));
                    },
                    hideForgotPasswordButton: true,
                    hideProvidersTitle: true,
                    onRecoverPassword: (String) {},
                    messages: LoginMessages(
                        userHint: 'מייל',
                        passwordHint: 'סיסמה',
                        loginButton: 'התחברות',
                        flushbarTitleError: 'שגיאה'),
                  ),
                ));
          }
      ),
    );
  }
}