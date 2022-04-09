import 'package:firebase_auth/firebase_auth.dart';
import 'package:nivapp/main.dart';
import 'package:nivapp/services/auth_service_i.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nivapp/services/routes_service_i.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nivapp/pickup_point.dart';
import 'package:nivapp/format_date.dart';
import 'package:nivapp/item_spec.dart';

class routes_service implements routes_service_i{
  /// Returns the items in current day's route.
  /// new name option: getDailyRoute.
  Future<List<PickupPoint>> getItems(
      {DateTime Function() getDay = DateTime.now}) async {
    final day = getDay();
    final route = FirebaseFirestore.instance.collection('routesTest');
    return route
        .where('date', isEqualTo: formatDate(day))
        .get()
        .then((res) => createPickupPointListFromRoute(res.docs));
  }

  Future<List<PickupPoint>> createPickupPointListFromRoute(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    List<PickupPoint> pickupPoints = [];
    for (var doc in docs) {
      final List<dynamic> pickupPointsJson = doc.data()['items'];
      // print('pickupPointsJson:');
      // print(pickupPointsJson);
      for (final pickup in pickupPointsJson) {
        final Item item = await getItemByID(pickup['itemID']);
        pickupPoints.add(PickupPoint(item: item, pickupTime: pickup['time']));
      }
    }
    return pickupPoints;
  }
  /// add route to firebase routes database from PickupPoint list.
  Future<void> addRouteByItemList(List<PickupPoint> list, DateTime date) async {
    bool found = false;
    //check if a route already exists, and if so, update it
    var ref = FirebaseFirestore.instance.collection('routesTest');
    var snapshot = await ref.where('date', isEqualTo: formatDate(date)).get();
    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs[0].reference.set({
        'items': list
            .map((pickup) =>
        {'itemID': pickup.item.id, 'time': pickup.pickupTime})
            .toList()
      });
      found = true;
    }
    //if no doc was found, add a new one
    if (!found) {
      ref.add({
        'date': formatDate(date),
        'items': list
            .map((pickup) =>
        {'itemID': pickup.item.id, 'time': pickup.pickupTime})
            .toList()
      });
    }
  }
}