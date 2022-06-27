import 'package:nivapp/route_planner/date_utility.dart';


String formatDate(DateTime date) {
  return date.year.toString() +
      '-' +
      date.month.toString() +
      '-' +
      date.day.toString();
}

String formatTimeRange(MyDateTimeRange? range) {
  if (range == null) return "";
  String start = range.start.hour < 10 ? '0' : '';
  start += range.start.hour.toString() + ":";
  start += (range.start.minute < 10 ? '0' : '') + range.start.minute.toString();
  String end = range.end.hour < 10 ? '0' : '';
  end += range.end.hour.toString() + ":";
  end += (range.end.minute < 10 ? '0' : '') + range.end.minute.toString();
  return start + ' - ' + end;

}
