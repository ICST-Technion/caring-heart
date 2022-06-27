// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:nivapp/easy_future_builder.dart';
import 'package:nivapp/item_spec.dart';
import 'package:nivapp/logic.dart';
import 'package:nivapp/main.dart';
import 'package:nivapp/pickup_point.dart';
import 'package:nivapp/route_planner/calendar_data.dart';
import 'package:nivapp/route_planner/date_utility.dart';
import 'package:nivapp/route_planner/route_dialog.dart';
import 'package:nivapp/route_planner/route_planner_provider.dart';
import 'package:nivapp/services/inventory_service_i.dart';
import 'package:nivapp/services/routes_service_i.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'dart:js' as js;

class RoutePlanner extends StatelessWidget {
  const RoutePlanner({Key? key}) : super(key: key);

  InventoryServiceI get inventoryService => injector.get();

  RoutesServiceI get routeService => injector.get();

  Future<Tuple2<List<Item>, List<PickupPoint>>>
      getItemsAndPickupPoints() async {
    List<Item> itemList = await inventoryService.getCheckedItems();
    List<PickupPoint> routeItems = await routeService.getAllPickupPoints();
    itemList.removeWhere(
        (item) => routeItems.map((e) => e.item).toList().contains(item));
    return Tuple2<List<Item>, List<PickupPoint>>(itemList, routeItems);
  }

  @override
  Widget build(BuildContext context) {
    return easyFutureBuilder<Tuple2<List<Item>, List<PickupPoint>>>(
        future: getItemsAndPickupPoints(),
        doneBuilder:
            (context, Tuple2<List<Item>, List<PickupPoint>> _itemListTuple) {
          return ChangeNotifierProvider(
              create: (context) => RoutePlannerProvider(routeService,
                  itemList: _itemListTuple.item1,
                  pickupPoints: _itemListTuple.item2),
              child: RoutePlannerUI());
        });
  }
}

class RoutePlannerUI extends StatefulWidget {
  const RoutePlannerUI({Key? key}) : super(key: key);

  @override
  State<RoutePlannerUI> createState() => _RoutePlannerUIState();
}

class _RoutePlannerUIState extends State<RoutePlannerUI> {
  late PickupPointDataSource calendarData;

  @override
  initState() {
    super.initState();
    calendarData = PickupPointDataSource(Logic.getRouteProvider(context, false)
        .selectedItems
        .map((p) => convertPickupPointToAppointment(p))
        .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
          appBar: AppBar(
              title: Center(child: Text("תכנון מסלול")),
              automaticallyImplyLeading: false,
              bottom: Logic.getRouteProvider(context, true).isUpdating
                  ? PreferredSize(
                      preferredSize: Size(double.infinity, 1.0),
                      child: LinearProgressIndicator(),
                    )
                  : null),
          body: Center(child: RoutePlanner2())),
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
      dataSource: calendarData,
      headerStyle: CalendarHeaderStyle(textAlign: TextAlign.center),
      timeSlotViewSettings: TimeSlotViewSettings(
          startHour: 8,
          endHour: 17,
          timeFormat: "HH:mm",
          timeInterval: Duration(minutes: 15),
          nonWorkingDays: <int>[DateTime.friday, DateTime.saturday]),
      onTap: (details) async {
        if (details.targetElement == CalendarElement.viewHeader) {
          js.context.callMethod('open', [getGoogleMapURL(details.date)]);
        } else {
          final p = await ShowRouteDialog(details);
          if (p != null) {
            if (p.runtimeType == PickupPoint) {
              await Logic.getRouteProvider(context, false)
                  .addPickupPointToDB(p);
              setState(() {
                calendarData.appointments!
                    .add(convertPickupPointToAppointment(p));
                calendarData =
                    PickupPointDataSource(calendarData.appointments!);
              });
            } else if (p.runtimeType == bool && p == true) {
              setState(() {
                calendarData.appointments!.remove(details.appointments![0]);
                calendarData =
                    PickupPointDataSource(calendarData.appointments!);
              });
              await Logic.getRouteProvider(context, false)
                  .removePickupPointFromDB(details.appointments![0].id);
            }
          }
        }
      },
      allowDragAndDrop: true,
      dragAndDropSettings: DragAndDropSettings(allowNavigation: false),
      allowAppointmentResize: true,
      onAppointmentResizeEnd: (details) async {
        setState(() {
          calendarData.snapAppointment(details.appointment!);
          calendarData = PickupPointDataSource(calendarData.appointments!);
        });
        await Logic.getRouteProvider(context, false).updatePickupPoint(
            details.appointment!, details.startTime!,
            endTime: details.endTime!);
      },
      onDragEnd: (details) async {
        if (details.droppingTime!.hour >= 8 &&
            details.droppingTime!.hour < 17) {
          setState(() {
            calendarData.snapAppointment(details.appointment!);
            calendarData = PickupPointDataSource(calendarData.appointments!);
          });
          await Logic.getRouteProvider(context, false)
              .updatePickupPoint(details.appointment!, details.droppingTime!);
        }
      },
    );
  }

  Appointment convertPickupPointToAppointment(PickupPoint p) {
    String _subject = p.item.name + " - " + p.item.description;
    return Appointment(
        startTime: p.pickupTime!.start,
        endTime: p.pickupTime!.end,
        id: p,
        subject: _subject,
        color: Colors.pinkAccent);
  }

  Future<dynamic> ShowRouteDialog(CalendarTapDetails details) async {
    final dialog = RouteDialog(
        items: Logic.getRouteProvider(context, false).itemList,
        selectedDateDetails: details);

    dynamic selected = await showDialog(
        context: context,
        builder: (_) => Directionality(
              textDirection: TextDirection.rtl,
              child: Dialog(child: dialog),
            ));

    final start = details.date!;
    final end = details.date!.add(Duration(minutes: 30));
    final range = MyDateTimeRange(start: start, end: end);
    if (selected != null) {
      if (selected.runtimeType == Item) {
        final pickupPoint = PickupPoint(item: selected, pickupTime: range);
        return pickupPoint;
      }
      return true;
    }
    return null;
  }

  getGoogleMapURL(DateTime? dateTime) {
    print(dateTime);
    final List<PickupPoint> route = Logic.getRouteProvider(context, false)
        .getDailyPickupPoints(PickupPoint(item: Item.emptyItem()), d: dateTime);
    String url = "https://www.google.com/maps/dir/לב חש/";
    for (final p in route) {
      final item = p.item;
      url += item.address + ", " + item.neighborhood + ", " + item.city + "/";
    }
    return url;
  }
}
