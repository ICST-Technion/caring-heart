import 'package:flutter/material.dart';
import 'package:time_range_picker/time_range_picker.dart';

import 'item_spec.dart';

class PickupPoint {
  final Item item;
  late final TimeRange? pickupTime;

  PickupPoint({required this.item, this.pickupTime});

  factory PickupPoint.fromString(Item item, String pickupTimeStr) {
    String start = pickupTimeStr.substring(0, pickupTimeStr.indexOf(' - '));
    String end = pickupTimeStr.substring(pickupTimeStr.lastIndexOf(' ') + 1);
    TimeOfDay startTime = TimeOfDay(
        hour: int.parse(start.substring(0, start.indexOf(':'))),
        minute: int.parse(start.substring(start.indexOf(':') + 1)));
    TimeOfDay endTime = TimeOfDay(
        hour: int.parse(end.substring(0, end.indexOf(':'))),
        minute: int.parse(end.substring(end.indexOf(':') + 1)));
    return PickupPoint(
        item: item,
        pickupTime: TimeRange(startTime: startTime, endTime: endTime));
  }
}
