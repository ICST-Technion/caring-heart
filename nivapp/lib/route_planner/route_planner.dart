// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:nivapp/easy_future_builder.dart';
import 'package:nivapp/item_spec.dart';
import 'package:nivapp/logic.dart';
import 'package:nivapp/main.dart';
import 'package:nivapp/route_planner/route_dialog.dart';
import 'package:nivapp/route_planner/route_planner_provider.dart';
import 'package:nivapp/route_planner/selected_item_list.dart';
import 'package:nivapp/services/inventory_service_i.dart';
import 'package:nivapp/services/routes_service_i.dart';
import 'package:provider/provider.dart';

import 'date_utility.dart';

class RoutePlanner extends StatelessWidget {
  const RoutePlanner({Key? key}) : super(key: key);

  InventoryServiceI get inventoryService => injector.get();

  RoutesServiceI get routeService => injector.get();

  @override
  Widget build(BuildContext context) {
    return easyFutureBuilder<List<Item>>(
        future: inventoryService.getCheckedItems(),
        //getDay: () => DateTime(2021,12,22)),
        doneBuilder: (context, List<Item> _itemList) => ChangeNotifierProvider(
            create: (context) =>
                RoutePlannerProvider(routeService, itemList: _itemList),
            child: RoutePlannerUI(title: "תכנון מסלול")));
  }
}

class RoutePlannerUI extends StatefulWidget {
  const RoutePlannerUI({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<RoutePlannerUI> createState() => _RoutePlannerUIState();
}

class _RoutePlannerUIState extends State<RoutePlannerUI> {
  @override
  Widget build(BuildContext context) {
    if (!Logic.getRouteProvider(context, true).isInitRoute) {
      return easyFutureBuilder(
          future: Logic.getRouteProvider(context, false).initRoute(),
          doneBuilder: (context, result) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                  appBar: AppBar(title: Text("תכנון מסלול")),
                  body: RoutePlanner()),
            );
          });
    }
    else {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
            appBar: AppBar(title: Text("תכנון מסלול")),
            body: RoutePlanner()),
      );
    }
  }

  Widget RoutePlanner() {
    return SizedBox(
      width: Logic.ScreenSize(context).width,
      height: Logic.ScreenSize(context).height,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
            tooltip: 'בחירת שעות',
            child: Icon(Icons.more_time_rounded),
            onPressed: () {
              RouteDialog(
                      context: context,
                      selectedDate:
                          Logic.getRouteProvider(context, false).selectedDate)
                  .ShowRouteDialog();
            }),
        body: SingleChildScrollView(
          child: Column(children: [
            Logic.getRouteProvider(context, true).isLoading
                ? LinearProgressIndicator(minHeight: 9)
                : SizedBox(),
            DateBtn(),
            ItemList(),
            Text(
              'המוצרים שבחרת:',
              style: TextStyle(fontSize: 20),
            ),
            Divider(thickness: 1),
            SelectedList(context: context).SelectedItemList(true),
          ]),
        ),
      ),
    );
  }

  Widget ItemList() {
    return Column(
      children: [
        Container(
            child: Card(
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: getItem(context, -1)),
            margin: EdgeInsets.only(top: 10)),
        Card(
          margin: EdgeInsets.all(10),
          elevation: 4,
          child: Container(
            margin: EdgeInsets.only(top: 10),
            height: Logic.ScreenSize(context).height / 2.6,
            child: ListView.builder(
                shrinkWrap: true,
                itemCount:
                    Logic.getRouteProvider(context, true).itemList.length,
                itemBuilder: (context, idx) => getItem(context, idx)),
          ),
        ),
      ],
    );
  }

  Widget getItem(BuildContext context, int idx) {
    return Card(
        elevation: 0,
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
    List<Widget> textBoxes = [
      SizedBox(width: Logic.ScreenSize(context).width / 30)
    ];
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
    return Row(children: textBoxes);
  }

  Widget ItemInfo(int index) {
    Item item = Logic.getRouteProvider(context, true).itemList[index].item2;
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
                  DateUtil.formatDate(value),
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
          value: Logic.getRouteProvider(newContext, true).itemList[index].item1,
          onChanged: (value) {
            Logic.getRouteProvider(context, false).SelectItemAt(index);
          });
    }));
    return Row(children: textBoxes);
  }

  Widget MyMap() {
    return SizedBox(
        height: Logic.ScreenSize(context).height / 2,
        width: Logic.ScreenSize(context).width,
        child: Center(child: Container()));
  }

  Widget ExpandedSizedTextBox(String text) {
    return Expanded(child: SizedTextBox(text));
  }

  Widget SizedTextBox(String text) {
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

  void sortColumn(sort) {
    Logic.getRouteProvider(context, false).Sort(sort);
  }

  Widget DateBtn() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 10),
        Container(
            height: Logic.ScreenSize(context).height / 15,
            width: Logic.ScreenSize(context).width / 10,
            child: TextFormField(
                readOnly: true,
                textAlign: TextAlign.center,
                decoration: InputDecoration(border: OutlineInputBorder()),
                controller:
                    Logic.getRouteProvider(context, false).dateBtnTextCtrl,
                style: TextStyle(fontSize: 16))),
        TextButton(
            onPressed: () async {
              DateTime? date = await showDatePicker(
                  context: context,
                  initialDate:
                      Logic.getRouteProvider(context, false).selectedDate,
                  firstDate: DateTime(2020, 1),
                  lastDate: DateTime.now().add(Duration(days: 365)));
              await Logic.getRouteProvider(context, false).loadNewRoute(date);
            },
            child: Text('שינוי התאריך')),
      ],
    );
  }
}
