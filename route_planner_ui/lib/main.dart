// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:html';
import 'dart:ui' as ui;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:route_planner_ui/item_list_provider.dart';
import 'package:tuple/tuple.dart';
import 'item_service.dart' as DB;
import 'item.dart';
import 'package:provider/provider.dart';

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
                  list: snapshot.data!.map((e) => Tuple2(false, e)).toList()),
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
  MyHomePage({Key? key, required this.title, required this.itemList})
      : super(key: key);

  final String title;
  final List<Item> itemList;
  List<Item> selectedItems = [];
  String currentMapSrc = '';

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isAscending = true;
  Size _size = Size(1920, 1080);
  IFrameElement mapElement = IFrameElement();
  Widget map = Container();
  String apiKey = 'AIzaSyDQG8XUHA4I-7uSMU6Ph9rVSd9P2hsn-Sw';

  @override
  void initState() {
    widget.currentMapSrc = 'https://maps.openrouteservice.org/';
    mapElement.src = widget.currentMapSrc;
    mapElement.style.border = 'none';
    mapElement.width = _size.width.toString();
    mapElement.height = (_size.height / 2).toString();
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'iframeElement',
      (int viewId) => mapElement,
    );
    map = HtmlElementView(
      key: UniqueKey(),
      viewType: 'iframeElement',
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: RoutePlanner(),
      ),
    );
  }

  RoutePlanner() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: _size.width / 1.5,
          height: _size.height,
          child: Scaffold(
            floatingActionButton: FloatingActionButton(tooltip: 'שליחה', child: Icon(Icons.send), onPressed: ()=>SendRoute(),),
            body: SingleChildScrollView(
              child: Column(children: [
                ItemList(),
                Divider(thickness: 2),
                Text(
                  'המוצרים שבחרת:',
                  style: TextStyle(fontSize: 20),
                ),
                Divider(thickness: 2),
                SelectedItemList()
              ]),
            ),
          ),
        ),
        MyMap()
      ],
    );
  }

  ItemList() {
    return Column(
      children: [
        Container(
            child: getItem(context, -1), margin: EdgeInsets.only(top: 10)),
        Container(
          margin: EdgeInsets.only(top: 10),
          height: _size.height / 2.6,
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: Provider.of<ItemListProvider>(context, listen: true)
                  .list
                  .length,
              itemBuilder: (context, idx) => getItem(context, idx)),
        ),
      ],
    );
  }

  SelectedItemList() {
    if (widget.selectedItems.isNotEmpty) {
      return SizedBox(
        height: _size.height / 2.4,
        child: ReorderableList(
            shrinkWrap: true,
            itemBuilder: (context, idx) =>
                getSelectedItem(widget.selectedItems[idx], idx),
            itemCount: widget.selectedItems.length,
            onReorder: (prev, current) {
              setState(() {
                if (current > prev) {
                  current = current - 1;
                }
                final item = widget.selectedItems.removeAt(prev);
                widget.selectedItems.insert(current, item);
              });
            }),
      );
    } else {
      return Center(child: Text('לא נבחרו מוצרים'));
    }
  }

  getItem(context, idx) {
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

  getSelectedItem(item, idx) {
    return Card(
        key: ValueKey(item.id),
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
        elevation: 3,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SelectedItemInfo(item, idx),
          ),
        ));
  }

  HeadersInfo() {
    return Row(children: [
      SizedBox(width: _size.width / 30),
      ExpandedSizedTextBox('שם'),
      ExpandedSizedTextBox('כתובת'),
      InkWell(
        child: ExpandedSizedTextBox('שכונה'),
        onTap: () => sortColumn(sortByNeighbors),
      ),
      InkWell(
          child: ExpandedSizedTextBox('עיר'),
          onTap: () => sortColumn(sortByCity)),
      ExpandedSizedTextBox('טלפון'),
      ExpandedSizedTextBox('תיאור'),
      ExpandedSizedTextBox('קטגוריה'),
      InkWell(
          child: ExpandedSizedTextBox('תאריך'),
          onTap: () => sortColumn(sortByDate)),
      ExpandedSizedTextBox('הערות'),
    ]);
  }

  ItemInfo(int index) {
    Item item =
        Provider.of<ItemListProvider>(context, listen: true).list[index].item2;
    Map info = {
      'select': Provider.of<ItemListProvider>(context, listen: true)
          .list[index]
          .item1,
      0: item.name,
      1: item.address,
      2: item.neighborhood,
      3: item.city,
      4: item.phone,
      5: item.description,
      6: item.category,
      7: item.date,
      8: item.comments,
    };
    List<Widget> textBoxes = [];
    info.forEach((key, value) {
      if (value.runtimeType == DateTime) {
        textBoxes.add(Expanded(
          child: SizedBox(
              width: _size.width / 12,
              height: _size.height / 20,
              child: Center(
                child: Text(
                  formatDate(value),
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
              )),
        ));
      } else if (value.runtimeType == bool) {
        textBoxes.add(Builder(builder: (newContext) {
          return Switch(
              value: Provider.of<ItemListProvider>(context, listen: true)
                  .list[index]
                  .item1,
              onChanged: (value) {
                Provider.of<ItemListProvider>(newContext, listen: false)
                    .SelectItemAt(index);
                setState(() {
                  if (value) {
                    widget.selectedItems.add(item);
                  } else {
                    widget.selectedItems.remove(item);
                  }
                });
              });
        }));
      } else {
        textBoxes.add(Expanded(
          child: SizedBox(
              width: _size.width / 12,
              height: _size.height / 20,
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
    return Row(children: textBoxes);
  }

  SelectedItemInfo(Item item, idx) {
    Map info = {
      -1: "",
      0: item.name,
      1: item.address,
      2: item.neighborhood,
      3: item.city,
      4: item.phone,
      5: item.description,
      6: item.category,
      7: item.date,
      8: item.comments,
    };
    List<Widget> textBoxes = [];
    info.forEach((key, value) {
      if (key == -1) {
        textBoxes.add(ReorderableDragStartListener(
            index: idx, child: const Icon(Icons.drag_handle)));
      } else if (value.runtimeType == DateTime) {
        textBoxes.add(Expanded(
          child: SizedBox(
              width: _size.width / 12,
              height: _size.height / 20,
              child: Center(
                child: Text(
                  formatDate(value),
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
              )),
        ));
      } else {
        textBoxes.add(Expanded(
          child: SizedBox(
              width: _size.width / 12,
              height: _size.height / 20,
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
    return Directionality(
        textDirection: TextDirection.rtl, child: Row(children: textBoxes));
  }

  MyMap() {
    return SizedBox(
        height: _size.height,
        width: _size.width / 3,
        child: Stack(
          children: [
            map,
            Center(
                child: Card(
                  elevation: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    child: Text("to be implemented", style: TextStyle(fontSize: 20)),
                  ),
                ))
          ],
        ));
  }

  ExpandedSizedTextBox(text) {
    return Expanded(
        child: SizedBox(
            width: _size.width / 12,
            height: _size.height / 20,
            child: Center(
                child: Text(
              text,
              style: TextStyle(fontWeight: FontWeight.bold),
            ))));
  }

  sortColumn(sort) {
    _isAscending = !_isAscending;
    Provider.of<ItemListProvider>(context, listen: false)
        .Sort(sort, _isAscending);
  }

  sortByNeighbors(a, b) {
    return a.neighborhood.compareTo(b.neighborhood);
  }

  sortByCity(a, b) {
    return a.city.compareTo(b.city);
  }

  sortByDate(a, b) {
    return a.date.compareTo(b.date);
  }

  String formatDate(DateTime date) {
    return date.day.toString() +
        '/' +
        date.month.toString() +
        '/' +
        date.year.toString();
  }

  SendRoute() {
    //todo: open dialog to add pickup times and upload to DB
  }
}
