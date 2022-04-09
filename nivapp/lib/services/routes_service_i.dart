import 'package:nivapp/pickup_point.dart';
import 'package:nivapp/format_date.dart';
import 'package:nivapp/item_spec.dart';


abstract class routes_service_i{
  /// Returns the items in current day's route.
  /// new name option: getDailyRoute.
  Future<List<PickupPoint>> getItems({DateTime Function() getDay = DateTime.now});

  /// returns PickupPoint list of point's in today's route from docs.
  Future<List<PickupPoint>> createPickupPointListFromRoute(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs);

  /// add route to firebase routes database from PickupPoint list.
  Future<void> addRouteByItemList(List<PickupPoint> list, DateTime date);
}