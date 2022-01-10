import 'package:item_spec/pickup_point.dart';
import 'package:tuple/tuple.dart';

import 'package:item_spec/item_spec.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemService {
  ItemService();

  Future<List<Item>> getCheckedItems() async {
    final ref = FirebaseFirestore.instance.collection('inventoryTest');
    return ref
        .where('isCollected', isEqualTo: false)
        .get()
        .then((res) => createItemListFromInventory(res.docs));
  }

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

  Future<void> addRouteByItemList(List<PickupPoint> list, DateTime date) async {
    final ref = FirebaseFirestore.instance.collection('routesTest');
    ref.add({
      'date': formatDate(date),
      'items': list
          .map(
              (pickup) => {'itemID': pickup.item.id, 'time': pickup.pickupTime})
          .toList()
    });
  }

  formatDate(DateTime date) {
    return date.year.toString() +
        '-' +
        date.month.toString() +
        '-' +
        date.day.toString();
  }
}
