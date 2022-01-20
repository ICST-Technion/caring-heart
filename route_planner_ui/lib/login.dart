
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:route_planner_ui/auth_service.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

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
            }
          }
          return Center(child: CircularProgressIndicator());
        });
  }

  Widget loginForm() {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: Scaffold(
        body: Builder(
            builder: (context) {
              return Center(
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: FlutterLogin(
                      onLogin: (LoginData data) =>
                          _auth.signInWithEmailPassword(data.name, data.password),
                      onSubmitAnimationCompleted: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => Container(), //change to app
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
      ),
    );
  }
}
