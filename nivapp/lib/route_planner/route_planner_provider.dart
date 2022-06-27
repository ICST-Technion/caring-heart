import 'package:flutter/material.dart';
import 'package:nivapp/item_spec.dart';
import 'package:nivapp/pickup_point.dart';
import 'package:nivapp/route_planner/calendar_data.dart';
import 'package:nivapp/services/routes_service_i.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:tuple/tuple.dart';

import 'date_utility.dart';

class RoutePlannerProvider with ChangeNotifier {
  late List<Tuple2<bool, Item>> itemList;
  Map<int, bool> isDayUpdated = {};
  List<PickupPoint> selectedItems = [];
  bool isLoading = false, isUpdating = false;
  final RoutesServiceI _routeService;

  //bool _isAscending = true;

  final TextEditingController _dateBtnTextCtrl = TextEditingController();

  TextEditingController get dateBtnTextCtrl => _dateBtnTextCtrl;

  RoutePlannerProvider(this._routeService,
      {required List<Item> itemList, required List<PickupPoint> pickupPoints}) {
    this.itemList = itemList.map((item) => Tuple2(false, item)).toList();
    this.itemList.sort(sortByUrgency);
    _dateBtnTextCtrl.text = DateUtil.formatDate(DateTime.now());
    selectedItems = pickupPoints;
  }

  int sortByUrgency(Tuple2 a, Tuple2 b) {
    int result = 0;
    if (a.item2.comments.contains("דחוף")) {
      result--;
    }
    if (a.item2.comments.contains("דחוף")) {
      result++;
    }
    return result;
  }

  /*void Sort(int Function(Item, Item) sortFunc) {
    _isAscending = !_isAscending;
    _isAscending
        ? itemList.sort((a, b) => sortFunc(a.item2, b.item2))
        : itemList.sort((a, b) => sortFunc(b.item2, a.item2));
    notifyListeners();
  }*/

  bool isSelectedEmpty() {
    return selectedItems.isEmpty;
  }

  /*bool isThereEmptyPickupTime() {
    return selectedItemsPerDay.values.any((itemList) => itemList.any((time) => time == null));
  }*/

  Future<void> addPickupPointToDB(PickupPoint pickupPoint) async {
    selectedItems.add(pickupPoint);
    itemList.removeWhere((t) => t.item2 == pickupPoint.item);
    this.itemList.sort(sortByUrgency);
    isUpdating = true;
    notifyListeners();
    await _routeService
        .addRouteByItemList([pickupPoint], pickupPoint.pickupTime!.start);
    isUpdating = false;
    notifyListeners();
  }

  List<PickupPoint> getDailyPickupPoints(PickupPoint p, {DateTime? d}) {
    final date = d ?? p.pickupTime!.start;
    return selectedItems
        .where((element) =>
            element.pickupTime!.start.day == date.day &&
            element.pickupTime!.start.month == date.month &&
            element.pickupTime!.start.year == date.year)
        .toList();
  }

  Future<void> updatePickupPoint(dynamic app, DateTime startTime,
      {DateTime? endTime}) async {
    isUpdating = true;
    notifyListeners();
    final p = app.id;
    selectedItems.remove(p);
    final DateTime prevDate = p.pickupTime!.start;
    final List<PickupPoint> prevRoute = getDailyPickupPoints(p);
    final minuteDiff =
        p.pickupTime!.end.difference(p.pickupTime!.start).inMinutes;
    p.pickupTime = MyDateTimeRange(
        start: DateUtil.getNearestTimeSlot(startTime),
        end: DateUtil.getNearestTimeSlot(
            endTime ?? startTime.add(Duration(minutes: minuteDiff))));
    selectedItems.add(p);

    await _routeService.replaceRoute(
        prevRoute, getDailyPickupPoints(p), prevDate, p.pickupTime!.start);
    isUpdating = false;
    notifyListeners();
  }

  removePickupPointFromDB(PickupPoint pickupPoint) async {
    final prevRoute = getDailyPickupPoints(pickupPoint);
    selectedItems.remove(pickupPoint);
    itemList.add(Tuple2<bool, Item>(false, pickupPoint.item));
    this.itemList.sort(sortByUrgency);
    isUpdating = true;
    notifyListeners();
    await _routeService.replaceRoute(
        prevRoute,
        getDailyPickupPoints(pickupPoint),
        pickupPoint.pickupTime!.start,
        pickupPoint.pickupTime!.start);
    isUpdating = false;
    notifyListeners();
  }
/*
  void changePickupTimeAt(int weekDay, int idx, TimeRange time) {
    selectedItemsPerDay[weekDay]![idx] = PickupPoint(
        item: selectedItemsPerDay[weekDay]![idx].item, pickupTime: time);
    notifyListeners();
  }

  List<PickupPoint>? getSelectedItems(DateTime startDate) {
    return selectedItemsPerDay[startDate.weekday]
        ?.where((pickupPoint) =>
            startDate.hasSameTimeAs(DateTime(pickupPoint.pickupTime.startTime)))
        .toList();
    return selectedItemsPerDay;
  }*/

/*void moveSelectedItemAt(prev, next) {
    final item = selectedItems.removeAt(prev);
    selectedItems.insert(next, item);
    notifyListeners();
  }*/
/*
  Future<void> addCurrentRoutesToDate(DateTime date) async {
    await _routeService.addRouteByItemList(selectedItems, date);
  }*/
}
