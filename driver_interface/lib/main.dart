// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:driver_interface/pickup_card.dart';
import 'package:expandable/expandable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:item_spec/pickup_point.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:item_spec/item_spec.dart';
import 'package:item_spec/driver_item_service.dart' as DB;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "AIzaSyAthHM9OIfBl2ZGEQXpLNNReIlscA0DDzY",
        authDomain: "caring-heart-aa1c1.firebaseapp.com",
        projectId: "caring-heart-aa1c1",
        storageBucket: "caring-heart-aa1c1.appspot.com",
        messagingSenderId: "182054728263",
        appId: "1:182054728263:web:148c0f7de618b0bfc07762",
        measurementId: "G-L7KXZNNTP3"),
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          // throw snapshot.error!;
          return ErrorScreen(snapshot.error.toString());
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp();
        }
        return Center(child: InitScreen());
      },
    );
  }

  Widget InitScreen() {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            CircularProgressIndicator(),
            Text(
              "מתחבר לשרת...",
              textDirection: TextDirection.rtl,
            )
          ]),
        ),
      ),
    );
  }

  Widget ErrorScreen(String error) {
    return MaterialApp(
        home: Scaffold(
            body:
                Center(child: Text(error, textDirection: TextDirection.ltr))));
  }
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final dayToShow = DateTime(2021, 12, 22); // TODO change to DateTime.now()
    final Future<List<PickupPoint>> _itemList =
        DB.ItemService().getItems(getDay: () => dayToShow);
    return FutureBuilder(
      future: _itemList,
      builder: (context, AsyncSnapshot<List<PickupPoint>> snapshot) {
        if (snapshot.hasError) {
          // throw snapshot.error!;
          return ErrorScreen(snapshot.error.toString());
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            title: 'מסלול יומי',
            theme: ThemeData(
              primarySwatch: Colors.pink,
            ),
            debugShowCheckedModeBanner: false,
            home: MyHomePage(title: 'מסלול יומי', itemList: snapshot.data!),
          );
        }
        return LoadingDataScreen();
      },
    );
  }

  Widget LoadingDataScreen() {
    return MaterialApp(
        home: Scaffold(
            body: Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        CircularProgressIndicator(),
        Text(
          "טוען נתונים...",
          textDirection: TextDirection.rtl,
        )
      ]),
    )));
  }

  Widget ErrorScreen(String error) {
    return MaterialApp(
        home: Scaffold(
            body:
                Center(child: Text(error, textDirection: TextDirection.ltr))));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title, required this.itemList})
      : super(key: key);

  final String title;
  final List<PickupPoint> itemList;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(child: ItemList(widget.itemList)),
      ),
    );
  }

  ItemList(List<PickupPoint> items) {
    return ListView(
      children: items
          .map((pp) => PickupCard(
              pickupPoint: pp, functionality: PickupCardFunctionality.log()))
          .toList(),
    );
  }

  AcceptItem(PickupPoint item) async {
    await DB.ItemService().collectItem(item.item.id);
    setState(() {
      widget.itemList.remove(item);
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('האיסוף הושלם'),
      duration: Duration(milliseconds: 1200),
    ));
  }

  RejectItem(PickupPoint item) {
    setState(() {
      widget.itemList.remove(item);
    });
  }
}
