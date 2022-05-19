import 'package:time_range_picker/time_range_picker.dart';

String formatDate(DateTime date) {
  return date.year.toString() +
      '-' +
      date.month.toString() +
      '-' +
      date.day.toString();
}

String formatTimeRange(TimeRange? range) {
  if (range == null) return "";
  String start = range.startTime.toString();
  start = start.substring(start.indexOf('(') + 1, start.lastIndexOf(')'));
  String end = range.endTime.toString();
  end = end.substring(end.indexOf('(') + 1, end.lastIndexOf(')'));
  return start + ' - ' + end;

}
