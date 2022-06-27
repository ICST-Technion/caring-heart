import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nivapp/services/inventory_service_i.dart';
import 'package:nivapp/services/routes_service_i.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nivapp/pickup_point.dart';
import 'package:nivapp/format_date.dart';

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
    final route = firebaseFirestore.collection('routes');
    return route
        .where('date', isEqualTo: formatDate(day))
        .get()
        .then((res) => _getPickupPointListFromRouteJson(res.docs[0].data()));
  }

  @override
  Future<List<PickupPoint>> getWeeklyItems(
      {DateTime Function() getCurrentDay = DateTime.now}) async {
    final day = getCurrentDay();
    final dailyItems = <PickupPoint>[];
    var currentDay = day.add(Duration(days: -1 * day.weekday));
    for (int i = 0; i < DateTime.daysPerWeek; i++) {
      dailyItems.addAll(await getItems(getDay: () => currentDay));
      currentDay = currentDay.add(const Duration(days: 1));
    }
    return dailyItems;
  }

  @override
  Future<List<PickupPoint>> getAllPickupPoints() async {
    final items = await firebaseFirestore.collection("routes").get();
    List<PickupPoint> pickupPoints = [];
    for (final doc in items.docs) {
      final temp = await _getPickupPointListFromRouteJson(doc.data());
      pickupPoints.addAll(temp);
    }
    return pickupPoints;
  }

  Future<List<PickupPoint>> _getPickupPointListFromRouteJson(
      Map<String, dynamic> routeJson) async {
    List<PickupPoint> pickupPoints = [];
    final dateStr = routeJson["date"];
    for (final itemStr in routeJson["items"]) {
      final item = await inventoryService.getItemByID(itemStr["itemID"]);
      pickupPoints.add(PickupPoint.fromString(item, itemStr["time"], dateStr));
    }

    return pickupPoints;
  }

  @override
  Future<void> replaceRoute(List<PickupPoint> prevRoute,
      List<PickupPoint> newRoute, DateTime prevDate, DateTime newDate) async {
    var ref = firebaseFirestore.collection('routes');
    var snapshot =
        await ref.where('date', isEqualTo: formatDate(prevDate)).get();
    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs[0].reference.set({
        'date': formatDate(prevDate),
        'items': newDate.day == prevDate.day
            ? newRoute
                .map((pickup) => {
                      'itemID': pickup.item.id,
                      'time': formatTimeRange(pickup.pickupTime)
                    })
                .toList()
            : prevRoute
                .map((pickup) => {
                      'itemID': pickup.item.id,
                      'time': formatTimeRange(pickup.pickupTime)
                    })
                .toList()
      }, SetOptions(merge: false));
    }
    if (newDate.day != prevDate.day) {
      await addRouteByItemList(newRoute, newDate);
    }
  }

  /// add route to firebase routes database from PickupPoint list.
  @override
  Future<void> addRouteByItemList(List<PickupPoint> list, DateTime date) async {
    bool found = false;
    //check if a route already exists, and if so, update it
    var ref = firebaseFirestore.collection('routes');
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
