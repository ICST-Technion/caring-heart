// import 'package:date_format/date_format.dart';

import 'package:item_spec/item_spec.dart';
import 'package:item_spec/pickup_point.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'format_date.dart';

/// Class for
class ItemService {
  ItemService();

  /// Returns all pickup points in route of a given day.
  ///
  /// [getDay] - a function object that returns the day of route.
  /// by default returns the current day.
  Future<List<PickupPoint>> getItems(
      {DateTime Function() getDay = DateTime.now}) async {
    final day = getDay();
    final route = FirebaseFirestore.instance.collection('routesTest');
    return route
        .where('date', isEqualTo: formatDate(day))
        .get()
        .then((res) => createPickupPointListFromRoute(res.docs));
  }
  /// Creates Pickup Point from route
  ///
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
  /// Returns an item object by its ID number.
  ///
  /// [id] - ID number of item to update.
  /// Returns Future<item> of corresponding item.
  Future<Item> getItemByID(String id) async {
    const collectionPath = 'inventoryTest';
    final inventory = FirebaseFirestore.instance.collection(collectionPath);
    final itemData = await inventory.doc(id).get();
    if (!itemData.exists) {
      throw Exception(
          '$id does not exists in firebase collection $collectionPath');
    }
    return Item.fromJson(id, itemData.data()!);
  }
  /// Changes item's collected status.
  ///
  /// [id] - ID number of item to update.
  Future<void> collectItem(id) async {
    final route = FirebaseFirestore.instance.collection('inventoryTest');
    await route.doc(id).update({
      'isCollected': true,
    });
  }
}
