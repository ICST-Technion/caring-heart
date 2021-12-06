import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'מסלול יומי',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'מסלול יומי'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final testList = [
      {
        'address': 'ויצמן 17, חיפה',
        'name': 'משה סלומון',
        'description': 'כסא',
        'phone': '0529981374',
        'time': '08:00'
      },
      {
        'address': 'שולמן 3, זכרון יעקב',
        'name': 'שמעון חדד',
        'description': 'סלון + מכונת כביסה',
        'phone': '0574498643',
        'time': '09:00'
      },
      {
        'address': 'בן יהודה 33, חיפה',
        'name': 'יעקב בר',
        'description': 'מיטה + מזרון',
        'phone': '0504442213',
        'time': '10:00'
      }
    ];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(child: itemList(testList)),
      ),
    );
  }

  itemList(dynamic items) {
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

  TopItem(item) {
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
              Divider(height: 1),
              AcceptOrReject(item)
            ],
          ),
        ));
  }

  ListItem(item) {
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

  Row ItemStuff(item) {
    final description = item['description'];
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      pickupInfo(item),
      Text(description, style: const TextStyle(fontSize: 18)),
      itemButtons(item)
    ]);
  }

  pickupInfo(item) {
    final address = item['address'];
    final time = item['time'];
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

  itemButtons(item) {
    final phone = item['phone'];
    final address = item['address'];
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

  AcceptOrReject(item) {
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
                  overlayColor: MaterialStateProperty.all<Color>(Colors.green.withAlpha(20)),
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

  AcceptItem(item) {
    //todo: backend
  }

  RejectItem(item) {
    //todo: backend
  }
}
