import 'package:flutter/material.dart';
import 'package:nivapp/services/inventory_service_i.dart';
import 'package:nivapp/services/routes_service_i.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nivapp/pickup_point.dart';
import 'package:nivapp/format_date.dart';
import 'package:nivapp/item_spec.dart';
import 'package:time_range_picker/time_range_picker.dart';

class RoutesService implements RoutesServiceI {
  final InventoryServiceI inventoryService;
  final FirebaseFirestore firebaseFirestore;

  RoutesService(this.inventoryService, this.firebaseFirestore);

  /// Returns the items in current day's route.
  /// new name option: getDailyRoute.
  @override
  Future<List<PickupPoint>> getItems(
      {DateTime Function() getDay = DateTime.now}) async {
    final day = getDay();
    final route = firebaseFirestore.collection('routesTest');
    return route
        .where('date', isEqualTo: formatDate(day))
        .get()
        .then((res) => _createPickupPointListFromRoute(res.docs));
  }

  Future<List<PickupPoint>> _createPickupPointListFromRoute(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    List<PickupPoint> pickupPoints = [];
    for (var doc in docs) {
      final List<dynamic> pickupPointsJson = doc.data()['items'];
      // print('pickupPointsJson:');
      // print(pickupPointsJson);
      for (final pickup in pickupPointsJson) {
        final Item item = await inventoryService.getItemByID(pickup['itemID']);
        pickupPoints.add(PickupPoint.fromString(item, pickup['time']));
      }
    }
    return pickupPoints;
  }

  /// add route to firebase routes database from PickupPoint list.
  @override
  Future<void> addRouteByItemList(List<PickupPoint> list, DateTime date) async {
    bool found = false;
    //check if a route already exists, and if so, update it
    var ref = firebaseFirestore.collection('routesTest');
    var snapshot = await ref.where('date', isEqualTo: formatDate(date)).get();
    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs[0].reference.set({
        'items': list
            .map((pickup) => {
                  'itemID': pickup.item.id,
                  'time': formatTimeRange(pickup.pickupTime)
                })
            .toList()
      }, SetOptions(merge: true));
      found = true;
    }
    //if no doc was found, add a new one
    if (!found) {
      ref.add({
        'date': formatDate(date),
        'items': list
            .map((pickup) => {
                  'itemID': pickup.item.id,
                  'time': formatTimeRange(pickup.pickupTime)
                })
            .toList()
      });
    }
  }
}
