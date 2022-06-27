import 'dart:html';

import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:nivapp/item_spec.dart';
import 'package:nivapp/logic.dart';
import 'package:nivapp/route_planner/date_utility.dart';
import 'package:nivapp/route_planner/item_info.dart';
import 'package:nivapp/route_planner/route_planner_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:tuple/tuple.dart';

enum RouteDialogStatus { success, noPickupTime, badDate, badTimes }

class RouteDialog extends StatefulWidget {
  final CalendarTapDetails selectedDateDetails;
  final List<Tuple2<bool, Item>> items;
  List<Item> notSelectedItems = [];
  int selectedIndex = -2;

  RouteDialog(
      {Key? key, required this.selectedDateDetails, required this.items})
      : super(key: key) {
    notSelectedItems =
        items.where((e) => !e.item1).map((e) => e.item2).toList();
  }

  @override
  State<RouteDialog> createState() => _RouteDialogState();
}

class _RouteDialogState extends State<RouteDialog> {
  @override
  Widget build(BuildContext context) {
    if (widget.selectedDateDetails.appointments != null &&
        widget.selectedDateDetails.appointments!.isNotEmpty) {
      return ItemInfoDialog(context);
    }
    return ChooseItemDialog(context);
  }

  Container ItemInfoDialog(BuildContext context) {
    return Container(
      width: Logic.ScreenSize(context).width * 0.81,
      margin: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            itemCard(-1,
                selectedItem:
                    widget.selectedDateDetails.appointments![0].id.item,
                elevate: false),
            Divider(thickness: 1),
            itemCard(0,
                selectedItem:
                    widget.selectedDateDetails.appointments![0].id.item,
                elevate: false),
            Divider(thickness: 1),
            deleteButton()
          ],
        ),
      ),
    );
  }

  Container ChooseItemDialog(BuildContext context) {
    return Container(
      width: Logic.ScreenSize(context).width * 0.81,
      margin: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(getDateText(widget.selectedDateDetails),
                style:
                    const TextStyle(fontSize: 21, fontWeight: FontWeight.w500)),
            const Divider(thickness: 1),
            const Text(
              'מוצרים שלא נאספו ומוכנים לאיסוף',
              style: TextStyle(fontSize: 20),
            ),
            itemListView(context),
            widget.selectedIndex != -2
                ? const Text(
                    'המוצר שבחרת',
                    style: TextStyle(fontSize: 20),
                  )
                : Container(),
            widget.selectedIndex != -2
                ? const Divider(thickness: 1)
                : Container(),
            widget.selectedIndex != -2
                ? itemCard(widget.selectedIndex, elevate: true)
                : Container(),
            widget.selectedIndex != -2 ? submitRow() : Container()
          ],
        ),
      ),
    );
  }

  Widget itemListView(BuildContext context) {
    return Column(
      children: [
        Container(
            child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: itemCard(-1)),
            margin: const EdgeInsets.only(top: 10)),
        Card(
          margin: const EdgeInsets.all(10),
          elevation: 4,
          child: Container(
            margin: const EdgeInsets.only(top: 10),
            height: Logic.ScreenSize(context).height / 2.6,
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.notSelectedItems.length,
                itemBuilder: (context, idx) => itemCard(idx)),
          ),
        ),
      ],
    );
  }

  Widget itemCard(int idx, {bool elevate = false, Item? selectedItem}) {
    if (selectedItem != null) {
      return Card(
          elevation: elevate ? 4 : 0,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: (idx == -1)
                  ? HeadersInfo(canChoose: false)
                  : itemInfoRow(idx,
                      showRadio: !elevate, selectedItem: selectedItem),
            ),
          ));
    }
    if (idx == -2) {
      return const Text("לא בחרת מוצר", style: TextStyle(fontSize: 16));
    }
    return Card(
        elevation: elevate ? 4 : 0,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: (idx == -1)
                ? HeadersInfo()
                : itemInfoRow(idx, showRadio: !elevate),
          ),
        ));
  }

  Widget HeadersInfo({bool canChoose = true}) {
    List titles = [
      'בחירה', //DOR SEE THIS PLEASE!
      'שם',
      'כתובת',
      'שכונה',
      'עיר',
      'טלפון 1',
      'טלפון 2',
      'תיאור',
      'תאריך',
      'הערות'
    ];
    if (!canChoose) {
      titles.remove('בחירה');
      print(titles[0]);
    }
    List<Widget> textBoxes = [];
    for (String element in titles) {
      Widget sizedBox = SizedBox(
          width:
              Logic.ScreenSize(context).width / (element == 'בחירה' ? 40 : 12),
          height: Logic.ScreenSize(context).height / 20,
          child: Center(
            child: Text(
              element,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ));
      if (element != 'בחירה') {
        sizedBox = Expanded(child: sizedBox);
      }
      textBoxes.add(sizedBox);
    }
    return Row(children: textBoxes);
  }

  Widget itemInfoRow(int index, {bool showRadio = true, Item? selectedItem}) {
    Item item = selectedItem ?? widget.notSelectedItems[index];
    List<Widget> textBoxes = ItemInfoTextBoxes(item, context);
    if (showRadio && selectedItem == null) {
      textBoxes.insert(0, Builder(builder: (newContext) {
        return SizedBox(
          width: Logic.ScreenSize(context).width / 40,
          child: Radio(
              value: index,
              groupValue: widget.selectedIndex,
              onChanged: (int? value) {
                setState(() {
                  widget.selectedIndex = value!;
                });
              }),
        );
      }));
    }
    return Row(children: textBoxes);
  }

  submitRow() {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [cancelButton(), submitButton()]),
    );
  }

  submitButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: ElevatedButton(
          onPressed: () {
            Navigator.of(context)
                .pop(widget.notSelectedItems[widget.selectedIndex]);
          },
          child: const Text("אישור", style: TextStyle(fontSize: 21)),
          style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12))),
    );
  }

  deleteButton() {
    return Container(
      width: 200,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("מחיקה מלוח השנה", style: TextStyle(fontSize: 16)),
              Icon(Icons.delete)
            ],
          ),
          style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12))),
    );
  }

  cancelButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            "ביטול",
            style: TextStyle(fontSize: 21, color: Colors.black),
          ),
          style: ElevatedButton.styleFrom(
              primary: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12))),
    );
  }

  String getDateText(CalendarTapDetails selectedDateDetails) {
    DateTime date = selectedDateDetails.date!;
    String txt = DateUtil.formatDate(date, getYear: false);
    txt += " - " + DateUtil.formatTime(date);
    return txt;
  }
}
