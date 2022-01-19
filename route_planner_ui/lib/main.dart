// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:async';
import 'dart:ui' as ui;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:item_spec/pickup_point.dart';
import 'package:route_planner_ui/item_list_provider.dart';
import 'package:route_planner_ui/selected_item_list.dart';
import 'package:tuple/tuple.dart';
import 'package:item_spec/route_item_service.dart' as DB;
import 'package:item_spec/item_spec.dart';
import 'package:provider/provider.dart';
import 'logic.dart';
import 'route_dialog.dart';

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
      debugShowCheckedModeBanner: false,
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

  final Future<List<Item>> _itemList = DB.ItemService().getCheckedItems();

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
            return ChangeNotifierProvider(
              create: (_) => ItemListProvider(
                  itemList:
                      snapshot.data!.map((e) => Tuple2(false, e)).toList(),
                  selectedItems: []),
              child: MaterialApp(
                title: 'תכנון מסלול',
                theme: ThemeData(
                  primarySwatch: Colors.pink,
                ),
                debugShowCheckedModeBanner: false,
                home:
                    MyHomePage(title: 'תכנון מסלול', itemList: snapshot.data!),
              ),
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
  var isLoading = false;

  MyHomePage({Key? key, required this.title, required this.itemList})
      : super(key: key);

  final String title;
  final List<Item> itemList;
  List<PickupPoint> selectedItems = [];

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isAscending = true;
  DateTime selectedDate = DateTime.now();
  TextEditingController ctrl = new TextEditingController();

  @override
  void initState() {
    ctrl.text = Logic.formatDate(DateTime.now());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(appBar: MyAppBar(), body: RoutePlanner()),
    );
  }

  AppBar MyAppBar() {
    return AppBar(
      title: Center(child: Text(widget.title)),
    );
  }

  Widget RoutePlanner() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: Logic.ScreenSize(context).width,
          height: Logic.ScreenSize(context).height,
          child: Scaffold(
            floatingActionButton: FloatingActionButton(
                tooltip: 'שליחה',
                child: Icon(Icons.send),
                onPressed: () {
                  RouteDialogFuncs(context: context, selectedDate: selectedDate)
                      .ShowRouteDialog();
                }),
            body: SingleChildScrollView(
              child: Column(children: [
                Logic.getProvider(context, true).isLoading
                    ? LinearProgressIndicator(minHeight: 9)
                    : SizedBox(),
                DateBtn(),
                ItemList(),
                Divider(thickness: 2),
                Text(
                  'המוצרים שבחרת:',
                  style: TextStyle(fontSize: 20),
                ),
                Divider(thickness: 2),
                SelectedList(context: context).SelectedItemList(true)
              ]),
            ),
          ),
        ),
        //MyMap()
      ],
    );
  }

  Widget ItemList() {
    return Column(
      children: [
        Container(
            child: getItem(context, -1), margin: EdgeInsets.only(top: 10)),
        Container(
          margin: EdgeInsets.only(top: 10),
          height: Logic.ScreenSize(context).height / 2.6,
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: Logic.getProvider(context, true).itemList.length,
              itemBuilder: (context, idx) => getItem(context, idx)),
        ),
      ],
    );
  }

  Widget getItem(context, idx) {
    return Card(
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
        elevation: 3,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: (idx == -1) ? HeadersInfo() : ItemInfo(idx),
          ),
        ));
  }

  Widget HeadersInfo() {
    List titles = [
      'שם',
      'כתובת',
      'שכונה',
      'עיר',
      'טלפון',
      'תיאור',
      'תאריך',
      'הערות'
    ];
    List<Widget> textBoxes = [SizedBox(width: Logic.ScreenSize(context).width / 30)];
    titles.forEach((element) {
      textBoxes.add(Expanded(
        child: SizedBox(
            width: Logic.ScreenSize(context).width / 12,
            height: Logic.ScreenSize(context).height / 20,
            child: Center(
              child: Text(
                element,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )),
      ));
    });
    return Row(children: textBoxes);/*
      SizedBox(width: Logic.ScreenSize(context).width / 30),
      ExpandedSizedTextBox('שם'),
      ExpandedSizedTextBox('כתובת'),
      InkWell(
        child: ExpandedSizedTextBox('שכונה'),
        onTap: () => sortColumn(Logic.sortByNeighbors),
      ),
      InkWell(
          child: ExpandedSizedTextBox('עיר'),
          onTap: () => sortColumn(Logic.sortByCity)),
      ExpandedSizedTextBox('טלפון'),
      ExpandedSizedTextBox('תיאור'),
      InkWell(
          child: ExpandedSizedTextBox('תאריך'),
          onTap: () => sortColumn(Logic.sortByDate)),
      ExpandedSizedTextBox('הערות'),
    ]);*/
  }

  Widget ItemInfo(int index) {
    Item item = Logic.getProvider(context, true).itemList[index].item2;
    Map info = {
      0: item.name,
      1: item.address,
      2: item.neighborhood,
      3: item.city,
      4: item.phone,
      5: item.description,
      6: item.date,
      7: item.comments,
    };
    List<Widget> textBoxes = [];
    info.forEach((key, value) {
      if (value.runtimeType == DateTime) {
        textBoxes.add(Expanded(
          child: SizedBox(
              width: Logic.ScreenSize(context).width / 12,
              height: Logic.ScreenSize(context).height / 20,
              child: Center(
                child: Text(
                  Logic.formatDate(value),
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
              )),
        ));
      } else {
        textBoxes.add(Expanded(
          child: SizedBox(
              width: Logic.ScreenSize(context).width / 12,
              height: Logic.ScreenSize(context).height / 20,
              child: Center(
                child: Tooltip(
                  textStyle: TextStyle(fontSize: 14),
                  decoration:
                      BoxDecoration(color: Color.fromARGB(255, 200, 200, 200)),
                  message: value,
                  child: Text(
                    value,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                ),
              )),
        ));
      }
    });
    textBoxes.insert(0, Builder(builder: (newContext) {
      return Switch(
          value: Logic.getProvider(newContext, true).itemList[index].item1,
          onChanged: (value) {
            Logic.getProvider(context, false).SelectItemAt(index);
          });
    }));
    return Row(children: textBoxes);
  }

  Widget MyMap() {
    return Expanded(
      child: SizedBox(
          height: Logic.ScreenSize(context).height,
          width: Logic.ScreenSize(context).width / 3,
          child: Center(child: Text('אני מפה'))),
    );
  }

  ExpandedSizedTextBox(text) {
    return Expanded(child: SizedTextBox(text));
  }

  Widget SizedTextBox(text) {
    return SizedBox(
        width: Logic.ScreenSize(context).width / 12,
        height: Logic.ScreenSize(context).height / 20,
        child: Center(
            child: Text(
          text,
          style: TextStyle(fontWeight: FontWeight.bold),
          overflow: TextOverflow.fade,
          softWrap: false,
        )));
  }

  sortColumn(sort) {
    _isAscending = !_isAscending;
    Logic.getProvider(context, false).Sort(sort, _isAscending);
  }

  Widget DateBtn() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 10),
        Container(
            height: Logic.ScreenSize(context).height / 21,
            width: Logic.ScreenSize(context).width / 15,
            child: TextFormField(
                readOnly: true,
                textAlign: TextAlign.center,
                decoration: InputDecoration(border: OutlineInputBorder()),
                controller: ctrl,
                style: TextStyle(fontSize: 16))),
        TextButton(
            onPressed: () async {
              DateTime? date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020, 1),
                  lastDate: DateTime.now().add(Duration(days: 365)));
              setState(() {
                selectedDate = date!;
                ctrl.text = Logic.formatDate(selectedDate);
                Logic.getProvider(context, false).loadNewRoute(date);
              });
            },
            child: Text('שינוי התאריך')),
      ],
    );
  }
}
