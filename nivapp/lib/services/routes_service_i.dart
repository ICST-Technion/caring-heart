import 'package:nivapp/pickup_point.dart';

DateTime today() => DateTime.now();

abstract class RoutesServiceI {
  /// Returns the items in current day's route.
  /// new name option: getDailyRoute.
  Future<List<PickupPoint>> getItems({DateTime Function() getDay = today});

  /// add route to firebase routes database from PickupPoint list.
  Future<void> addRouteByItemList(List<PickupPoint> list, DateTime date);


  Future<void> replaceRoute(List<PickupPoint> prevRoute,
      List<PickupPoint> newRoute, DateTime prevDate, DateTime newDate);

  Future<List<PickupPoint>> getWeeklyItems(
      {DateTime Function() getCurrentDay = today});

  Future<List<PickupPoint>> getAllPickupPoints();
}
