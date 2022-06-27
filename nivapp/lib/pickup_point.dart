import 'package:nivapp/route_planner/date_utility.dart';

import 'item_spec.dart';

class PickupPoint {
  final Item item;
  MyDateTimeRange? pickupTime;

  PickupPoint({required this.item, this.pickupTime});

  factory PickupPoint.fromString(
      Item item, String pickupTimeStr, String dateStr) {
    List<String> temp = dateStr.split("-");
    DateTime date =
        DateTime(int.parse(temp[0]), int.parse(temp[1]), int.parse(temp[2]));
    String start = pickupTimeStr.substring(0, pickupTimeStr.indexOf(' - '));
    String end = pickupTimeStr.substring(pickupTimeStr.lastIndexOf(' ') + 1);
    DateTime startTime = DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(start.substring(0, start.indexOf(':'))),
        int.parse(start.substring(start.indexOf(':') + 1)));
    DateTime endTime = DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(end.substring(0, end.indexOf(':'))),
        int.parse(end.substring(end.indexOf(':') + 1)));
    return PickupPoint(
        item: item,
        pickupTime: MyDateTimeRange(start: startTime, end: endTime));
  }
}
