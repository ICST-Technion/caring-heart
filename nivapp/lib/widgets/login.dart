import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:nivapp/main.dart';
import 'package:nivapp/services/auth_service_i.dart';

class Login extends StatefulWidget {
  const Login({Key? key, required this.redirection}) : super(key: key);

  final Widget Function(AuthServiceI) redirection;

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  AuthServiceI get _auth => injector.get();

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
              return widget.redirection(_auth);
            }
          }
          return const Center(child: CircularProgressIndicator());
        });
  }

  Widget loginForm() {
    return Scaffold(
      body: Builder(builder: (context) {
        return Center(
            child: Directionality(
          textDirection: TextDirection.ltr,
          child: FlutterLogin(
            theme: LoginTheme(pageColorLight: Color.fromARGB(255, 255, 123, 215)),
            onLogin: (LoginData data) =>
                _auth.signInWithEmailPassword(data.name, data.password),
            onSubmitAnimationCompleted: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => widget.redirection(_auth),
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
      }),
    );
  }
}
