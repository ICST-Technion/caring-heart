import 'package:flutter/material.dart';

class DateUtil {
  static String formatDate(DateTime date, {bool getYear = true}) {
    return date.day.toString() +
        '/' +
        date.month.toString() +
        (getYear ? '/' + date.year.toString() : "");
  }

  static int compareDates(DateTime d1, DateTime d2) {
    if (d1.compareTo(d2) == 0 ||
        (d1.year == d2.year && d1.month == d2.month && d1.day == d2.day)) {
      return 0;
    }
    return d1.compareTo(d2);
  }

  static String getHebrewWeekday(int day) {
    switch (day) {
      case DateTime.sunday:
        return "ראשון";
      case DateTime.monday:
        return "שני";
      case DateTime.tuesday:
        return "שלישי";
      case DateTime.wednesday:
        return "רביעי";
      case DateTime.thursday:
        return "חמישי";
      case DateTime.friday:
        return "שישי";
      case DateTime.saturday:
        return "שבת";
    }
    return "לא יודע";
  }

  static String dateRangeStringBuilder(DateTime date1, DateTime date2) {
    return "מהתאריך " + formatDate(date1) + " עד התאריך " + formatDate(date2);
  }

  static String formatTime(DateTime date) {
    int h = date.hour;
    int m = date.minute;
    String txt = h >= 10 ? h.toString() : "0" + h.toString();
    txt += ":" + (m >= 10 ? m.toString() : "0" + m.toString());
    return txt;
  }

  static DateTime getNearestTimeSlot(DateTime d) {
    print("DEBUG: " + d.minute.toString());
    if (d.minute % 15 == 0) {
      return d;
    }
    if (d.minute % 15 <= 7) {
      return d.subtract(Duration(minutes: d.minute % 15));
    }
    return d.add(Duration(minutes: 15 - d.minute % 15));
  }
}

class MyDateTimeRange {
  DateTime start;
  DateTime end;

  MyDateTimeRange({required this.start, required this.end});

  TimeOfDay getStartTime() {
    return TimeOfDay(hour: start.hour, minute: start.minute);
  }

  TimeOfDay getEndTime() {
    return TimeOfDay(hour: start.hour, minute: start.minute);
  }

  String toString() {
    return "Start: ${start.toString()} to ${end.toString()}";
  }

}
