import 'package:firebase_auth/firebase_auth.dart';
import 'package:nivapp/main.dart';
import 'package:nivapp/services/auth_service_i.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nivapp/services/inventory_service_i.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nivapp/pickup_point.dart';
import 'package:nivapp/format_date.dart';
import 'package:nivapp/item_spec.dart';

class InventoryService implements InventoryServiceI {
  /// returns item by its id.
  /// Items stuff
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
  /// Check item as collected.
  /// Items stuff.
  Future<void> collectItem(id) async {
    final route = FirebaseFirestore.instance.collection('inventoryTest');
    await route.doc(id).update({
      'isCollected': true,
    });
  }

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
}

