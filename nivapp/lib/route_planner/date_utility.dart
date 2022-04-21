
import 'package:nivapp/pickup_point.dart';

class DateUtil {
  static String formatDate(DateTime date) {
    return date.day.toString() +
        '/' +
        date.month.toString() +
        '/' +
        date.year.toString();
  }

  static int compareDates(DateTime d1, DateTime d2) {
    if (d1.compareTo(d2) == 0 ||
        (d1.year == d2.year && d1.month == d2.month && d1.day == d2.day)) {
      return 0;
    }
    return d1.compareTo(d2);
  }

}