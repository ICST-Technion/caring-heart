import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nivapp/item_spec.dart';
import 'package:nivapp/pickup_point.dart';
import 'package:nivapp/route_planner/date_utility.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class PickupPointDataSource extends CalendarDataSource {
  PickupPointDataSource(List<dynamic> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].startTime;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].endTime;
  }

  @override
  String getSubject(int index) {
    return appointments![index].subject;
  }

  void snapAppointment(Object? app) {
    Appointment a = appointments!.firstWhere((element) => element == app);
    a.startTime = DateUtil.getNearestTimeSlot(a.startTime);
    a.endTime = DateUtil.getNearestTimeSlot(a.endTime);
  }

  @override
  Object? getId(int index) {
    return appointments![index].id;
  }

  @override
  Color getColor(int index) => appointments![index].color;

  @override
  bool isAllDay(int index) => false;

  @override
  Appointment? convertAppointmentToObject(Object? data, Appointment app) {
    return Appointment(startTime: app.startTime, endTime: app.endTime, id: app.id);
  }
}
