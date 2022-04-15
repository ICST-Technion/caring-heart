import 'package:flutter/material.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:nivapp/driver_interface/driver_interface.dart';
import 'package:nivapp/easy_future_builder.dart';
import 'package:nivapp/offline_mock_module.dart';
import 'package:nivapp/production_module.dart';
import 'package:nivapp/services/auth_service_i.dart';
import 'package:nivapp/services/init_service.dart';
import 'package:nivapp/widgets/login.dart';

late final Injector injector;

void main() {
  const offline = false;
  if (offline) {
    injector = OfflineMockModule();
  } else {
    injector = ProductionModule();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NIVAPP',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      initialRoute: '/',
      routes: {
        '/': (c) => Container(child: Text("דף הבית")),
        // When navigating to the "/" route, build the FirstScreen widget.
        '/planner': (context) => MyHomePage(
              title: 'תכנון מסלול',
              getHomePage: () => Container(),
            ),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/drivers': (context) => easyFutureBuilder(
            future: injector.get<InitService>().init(),
            doneBuilder: (context, result) =>
                Login(redirection: (authService) => const DriverInterface())),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key? key, required this.title, required this.getHomePage})
      : super(key: key);
  final String title;
  final Widget Function() getHomePage;
  final _auth = injector.get<AuthServiceI>();
  final _init = injector.get<InitService>();

  @override
  Widget build(BuildContext context) {
    // Logic.getProvider(context, false).loadNewRoute(selectedDate, notify: false);
    return FutureBuilder(
      future: _init.init(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorScreen(snapshot.error.toString());
        }
        // if (snapshot.connectionState == ConnectionState.done) {
        //   return Login(func: (a) => MyApp(auth: a));
        // }
        return Center(child: LoadingDataScreen());
      },
    );
  }

  Widget ErrorScreen(String error) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            body:
                Center(child: Text(error, textDirection: TextDirection.ltr))));
  }

  AppBar MyAppBar() {
    // TODO insert injector for auth

    // if (! await _auth.isUserRemembered()) {
    return AppBar(title: Text(title));
    // }
    // return AppBar(title: Text(widget.title), actions: [
    //   IconButton(
    //       onPressed: () async {
    //         await widget.auth.signOut();
    //         Navigator.of(context).pushReplacement(MaterialPageRoute(
    //           builder: (context) => Login(func: (a) => MyApp(auth: a)),
    //         ));
    //       },
    //       icon: Icon(Icons.logout))
    // ]);
  }
}

class LoadingDataScreen extends StatelessWidget {
  const LoadingDataScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        CircularProgressIndicator(),
        Text(
          "טוען נתונים...",
          textDirection: TextDirection.rtl,
        )
      ]),
    ));
  }
}
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key, required this.title}) : super(key: key);

//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.

//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return WillPopScope(
//       onWillPop: () async => false,
//       child: Scaffold(
//         appBar: AppBar(
//             // Here we take the value from the MyHomePage object that was created by
//             // the App.build method, and use it to set our appbar title.
//             title: Text(widget.title),
//             automaticallyImplyLeading: false),
//         body: Center(
//           // Center is a layout widget. It takes a single child and positions it
//           // in the middle of the parent.
//           child: Column(
//             // Column is also a layout widget. It takes a list of children and
//             // arranges them vertically. By default, it sizes itself to fit its
//             // children horizontally, and tries to be as tall as its parent.
//             //
//             // Invoke "debug painting" (press "p" in the console, choose the
//             // "Toggle Debug Paint" action from the Flutter Inspector in Android
//             // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
//             // to see the wireframe for each widget.
//             //
//             // Column has various properties to control how it sizes itself and
//             // how it positions its children. Here we use mainAxisAlignment to
//             // center the children vertically; the main axis here is the vertical
//             // axis because Columns are vertical (the cross axis would be
//             // horizontal).
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               const Text(
//                 'You have pushed the button this many times:',
//               ),
//               Text(
//                 '$_counter',
//                 style: Theme.of(context).textTheme.headline4,
//               ),
//             ],
//           ),
//         ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: _incrementCounter,
//           tooltip: 'Increment',
//           child: const Icon(Icons.add),
//         ), // This trailing comma makes auto-formatting nicer for build methods.
//       ),
//     );
//   }
// }
