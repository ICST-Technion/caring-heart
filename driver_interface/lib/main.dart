// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'item.dart';
import 'item_service.dart' as DB;

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

  final Future<List<Item>> _itemList = DB.ItemService().getItems();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _itemList,
        builder: (context, AsyncSnapshot<List<Item>> snapshot) {
          if (snapshot.hasError) {
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
        });
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
  final List<Item> itemList;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    /*final testList = [
      {
        'address': 'ויצמן 17, חיפה',
        'name': 'משה סלומון',
        'category': 'כסא',
        'phone': '0529981374',
        'time': '08:00'
      },
      {
        'address': 'שולמן 3, זכרון יעקב',
        'name': 'שמעון חדד',
        'category': 'סלון + מכונת כביסה',
        'phone': '0574498643',
        'time': '09:00'
      },
      {
        'address': 'בן יהודה 33, חיפה',
        'name': 'יעקב בר',
        'category': 'מיטה + מזרון',
        'phone': '0504442213',
        'time': '10:00'
      }
    ];*/
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(child: ItemList(widget.itemList)),
        bottomNavigationBar: BottomNavBar(),
      ),
    );
  }

  BottomNavBar() {
    return BottomNavigationBar(
      currentIndex: 0, // this will be set when a new tab is tapped
      items: [
        BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined), label: 'מסלול יומי'),
        BottomNavigationBarItem(
            icon: Icon(Icons.calendar_view_week), label: 'מסלולים שבועיים'),
        BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz), label: 'פריטים שנאספו')
      ],
    );
  }

  ItemList(List<Item> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, int index) {
        if (index == 0) {
          return TopItem(items[index]);
        }
        return ListItem(items[index]);
      },
    );
  }

  TopItem(Item item) {
    return Card(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        elevation: 4,
        child: Center(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: ItemStuff(item),
              ),
              const Divider(height: 1),
              AcceptOrReject(item)
            ],
          ),
        ));
  }

  ListItem(Item item) {
    return Card(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        elevation: 4,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: ItemStuff(item),
          ),
        ));
  }

  Row ItemStuff(Item item) {
    final category = item.category;
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      pickupInfo(item),
      Text(category, style: const TextStyle(fontSize: 18)),
      itemButtons(item)
    ]);
  }

  pickupInfo(Item item) {
    final address = item.address;
    final time = item.pickupTime;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(address, style: const TextStyle(fontSize: 20)),
            Text(time, style: const TextStyle(fontSize: 16))
          ],
        )
      ],
    );
  }

  itemButtons(Item item) {
    final phone = item.phone;
    final address = item.address;
    return Column(
      children: [
        IconButton(
            splashRadius: 24,
            onPressed: () => launch('tel:$phone'),
            icon: const Icon(Icons.phone, color: Colors.green)),
        IconButton(
            splashRadius: 24,
            onPressed: () => launch('https://waze.com/ul?q=$address'),
            icon: const Icon(Icons.map, color: Colors.blue))
      ],
    );
  }

  AcceptOrReject(Item item) {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: TextButton(
                onPressed: () => AcceptItem(item),
                child: const Text(
                  'אישור',
                  style: TextStyle(color: Colors.green, fontSize: 18),
                ),
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.symmetric(vertical: 15)),
                  overlayColor: MaterialStateProperty.all<Color>(
                      Colors.green.withAlpha(20)),
                )),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: TextButton(
                onPressed: () => RejectItem(item),
                child: const Text('ביטול',
                    style: TextStyle(color: Colors.red, fontSize: 18)),
                style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.symmetric(vertical: 15)))),
          ),
        ],
      ),
    );
  }

  AcceptItem(Item item) {
    //todo: backend
  }

  RejectItem(Item item) {
    //todo: backend
  }
}
