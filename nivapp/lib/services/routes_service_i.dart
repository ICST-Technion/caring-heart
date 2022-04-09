import 'package:nivapp/pickup_point.dart';

abstract class RoutesServiceI {
  /// Returns the items in current day's route.
  /// new name option: getDailyRoute.
  Future<List<PickupPoint>> getItems(
      {DateTime Function() getDay = DateTime.now});

  /// add route to firebase routes database from PickupPoint list.
  Future<void> addRouteByItemList(List<PickupPoint> list, DateTime date);
}
