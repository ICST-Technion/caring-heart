import 'package:item_spec/pickup_point.dart';
import 'package:tuple/tuple.dart';

import 'package:item_spec/item_spec.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'format_date.dart';

class ItemService {
  ItemService();
  /// Returns all collected items.
  /// Items stuff
  Future<List<Item>> getCheckedItems() async { // TODO: might have bugs.
    final ref = FirebaseFirestore.instance.collection('inventoryTest');
    return ref
        .where('isCollected', isEqualTo: false) 
        .get()
        .then((res) => createItemListFromInventory(res.docs));
  }

  /// Returns Item list from firebase json data of all items.
  /// items stuff.
  Future<List<Item>> createItemListFromInventory(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    List<Item> items = [];
    for (var doc in docs) {
      if (doc.data()['isChecked']) {
        items.add(Item.fromJson(doc.id, doc.data()));
      }
    }
    return items;
  }
  /// add route to firebase routes database from PickupPoint list.
  /// route stuff?
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
