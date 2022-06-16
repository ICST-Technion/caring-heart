// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:nivapp/easy_future_builder.dart';
import 'package:nivapp/item_spec.dart';
import 'package:nivapp/logic.dart';
import 'package:nivapp/main.dart';
import 'package:nivapp/pickup_point.dart';
import 'package:nivapp/route_planner/item_info.dart';
import 'package:nivapp/route_planner/route_dialog.dart';
import 'package:nivapp/route_planner/route_planner_provider.dart';
import 'package:nivapp/route_planner/selected_item_list.dart';
import 'package:nivapp/services/inventory_service_i.dart';
import 'package:nivapp/services/routes_service_i.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:collection/collection.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'date_utility.dart';

class RoutePlanner extends StatelessWidget {
  const RoutePlanner({Key? key}) : super(key: key);

  InventoryServiceI get inventoryService => injector.get();

  RoutesServiceI get routeService => injector.get();

  Future<Tuple2<List<Item>, List<PickupPoint>>>
      getItemsAndCurrentRoute() async {
    List<Item> itemList = await inventoryService.getCheckedItems();
    List<PickupPoint> routeItems = await routeService.getItems();
    return Tuple2<List<Item>, List<PickupPoint>>(itemList, routeItems);
  }

  @override
  Widget build(BuildContext context) {
    return easyFutureBuilder<Tuple2<List<Item>, List<PickupPoint>>>(
        future: getItemsAndCurrentRoute(),
        //getDay: () => DateTime(2021,12,22)),
        doneBuilder:
            (context, Tuple2<List<Item>, List<PickupPoint>> _itemListTuple) =>
                ChangeNotifierProvider(
                    create: (context) => RoutePlannerProvider(routeService,
                        itemList: _itemListTuple.item1,
                        route: _itemListTuple.item2),
                    child: CalendarControllerProvider(
                        controller: EventController(),
                        child: RoutePlannerUI(title: "תכנון מסלול"))));
  }
}

class RoutePlannerUI extends StatefulWidget {
  const RoutePlannerUI({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<RoutePlannerUI> createState() => _RoutePlannerUIState();
}

class _RoutePlannerUIState extends State<RoutePlannerUI> {
  final GlobalKey<WeekViewState> _calendarKey = GlobalKey<WeekViewState>();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Center(child: Text("תכנון מסלול")),
          automaticallyImplyLeading: false,
        ),
        body: Center(child: RoutePlanner2()),
        floatingActionButton: ChooseTimesFAB(),
      ),
    );
  }

  Widget RoutePlanner2() {
    return SizedBox(
        width: Logic.ScreenSize(context).width,
        height: Logic.ScreenSize(context).height,
        child: PrettyCalendar());
  }

  Widget PrettyCalendar() {
    return SfCalendar(
      view: CalendarView.week,
      showNavigationArrow: true,
      headerStyle: CalendarHeaderStyle(textAlign: TextAlign.center),
      timeSlotViewSettings: TimeSlotViewSettings(
          startHour: 9,
          endHour: 16,
          timeFormat: "HH:mm",
          timeInterval: Duration(minutes: 15),
          nonWorkingDays: <int>[DateTime.friday, DateTime.saturday]),
      onTap: (details) { openChooseItemDialog(); },
    );
  }

  void openChooseItemDialog() {}


  /*Widget WeeklyCalendar() {
    final event = CalendarEventData(
      title: "Eventy centy",
      date: DateTime(2022, 5, 15),
      event: "Event 1",
    );

    CalendarControllerProvider.of(context).controller.add(event);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: WeekView(
        key: _calendarKey,
        controller: CalendarControllerProvider.of(context).controller,
        timeLineBuilder: (date) {
          String str = (date.hour < 10)
              ? "0" + date.hour.toString()
              : date.hour.toString();
          str += ":";
          str += (date.minute < 10)
              ? "0" + date.minute.toString()
              : date.minute.toString();
          return Text(str);
        },
        weekDayBuilder: (date) {
          return Text(DateUtil.getHebrewWeekday(date.weekday) +
              "\n" +
              date.day.toString() +
              "/" +
              date.month.toString());
        },
        weekPageHeaderBuilder: (date1, date2) {
          return CalendarHeader(date1, date2);
        },
        // To display live time line in all pages in week view.
        // width of week view.
        minDay: DateTime(2020),
        maxDay: DateTime.now().add(Duration(days: 365)),
        initialDay: DateTime.now(),
        heightPerMinute: 0.5,
        // height occupied by 1 minute time span.
        eventArranger: SideEventArranger(),
        // To define how simultaneous events will be arranged.
        onEventTap: (events, date) => print(events),
        onDateLongPress: (date) => print(date),
        startDay: WeekDays.sunday,
        // To change the first day of the week.
        weekDays: [
          WeekDays.sunday,
          WeekDays.monday,
          WeekDays.tuesday,
          WeekDays.wednesday,
          WeekDays.thursday
        ],
      ),
    );
  }

  Widget CalendarHeader(DateTime startDate, DateTime endDate) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.lightBlue.withOpacity(0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              _calendarKey.currentState?.previousPage();
            },
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            icon: Icon(
              Icons.chevron_left,
              size: 30,
              color: Colors.black,
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: startDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );

                if (selectedDate == null) return;
                _calendarKey.currentState?.jumpToPage(DateTime(2020)
                    .getWeekDifference(selectedDate, start: WeekDays.sunday));
              },
              child: Text(
                DateUtil.dateRangeStringBuilder(startDate, endDate),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              _calendarKey.currentState?.nextPage();
            },
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            icon: Icon(
              Icons.chevron_right,
              size: 30,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
*/
  Widget RoutePlanner() {
    return SizedBox(
      width: Logic.ScreenSize(context).width,
      height: Logic.ScreenSize(context).height,
      child: SingleChildScrollView(
        child: Column(children: [
          Logic.getRouteProvider(context, true).isLoading
              ? LinearProgressIndicator(minHeight: 9)
              : SizedBox(),
          DateBtn(),
          Text(
            'מוצרים שלא נאספו ומוכנים לאיסוף',
            style: TextStyle(fontSize: 20),
          ),
          ItemList(),
          Text(
            'המוצרים שבחרת',
            style: TextStyle(fontSize: 20),
          ),
          Divider(thickness: 1),
          SelectedList(context: context).SelectedItemList(true),
        ]),
      ),
    );
  }

  FloatingActionButton ChooseTimesFAB() {
    return FloatingActionButton.extended(
        label: Text('בחירת שעות'),
        isExtended: true,
        icon: Icon(Icons.more_time_rounded),
        onPressed: () {
          RouteDialog(
                  context: context,
                  selectedDate:
                      Logic.getRouteProvider(context, false).selectedDate)
              .ShowRouteDialog();
        });
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
      '   בחירה', //DOR SEE THIS PLEASE!
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
    List<Widget> textBoxes = [
      // SizedBox(width: Logic.ScreenSize(context).width / 30)
    ];
    // titles.fo
    titles.forEachIndexed((i, element) {
      Widget sizedBox = SizedBox(
          width: Logic.ScreenSize(context).width / (i == 0 ? 30 : 12),
          height: Logic.ScreenSize(context).height / 20,
          child: Center(
            child: Text(
              element,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ));
      if (i != 0) {
        sizedBox = Expanded(child: sizedBox);
      }
      textBoxes.add(sizedBox);
    });
    return Row(children: textBoxes);
  }

  Widget ItemInfo(int index) {
    Item item = Logic.getRouteProvider(context, true).itemList[index].item2;
    List<Widget> textBoxes = ItemInfoTextBoxes(item, context);
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
            height: Logic.ScreenSize(context).height / 17,
            width: Logic.ScreenSize(context).width / 10,
            child: TextButton(
                style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            side: BorderSide(color: Colors.pinkAccent)))),
                onPressed: () async {
                  DateTime? date = await showDatePicker(
                      context: context,
                      initialDate:
                          Logic.getRouteProvider(context, false).selectedDate,
                      firstDate: DateTime(2020, 1),
                      lastDate: DateTime.now().add(Duration(days: 365)));
                  await Logic.getRouteProvider(context, false)
                      .loadNewRoute(date);
                },
                child: TextField(
                    textAlignVertical: TextAlignVertical.center,
                    enabled: false,
                    mouseCursor: SystemMouseCursors.click,
                    readOnly: true,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(border: InputBorder.none),
                    controller:
                        Logic.getRouteProvider(context, false).dateBtnTextCtrl,
                    style: TextStyle(fontSize: 18)))),
        SizedBox(height: 4)
      ],
    );
  }

}
