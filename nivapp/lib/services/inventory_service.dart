import 'package:nivapp/services/inventory_service_i.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nivapp/item_spec.dart';

class InventoryService implements InventoryServiceI {
  final FirebaseFirestore fbInstance;
  InventoryService(this.fbInstance);

  /// returns item by its id.
  /// Items stuff
  @override
  Future<Item> getItemByID(String id) async {
    const collectionPath = 'inventoryTest';
    final inventory = fbInstance.collection(collectionPath);
    final itemData = await inventory.doc(id).get();
    if (!itemData.exists) {
      throw Exception(
          '$id does not exists in firebase collection $collectionPath');
    }
    return Item.fromJson(id, itemData.data()!);
  }

  /// Check item as collected.
  /// Items stuff.
  @override
  Future<void> collectItem(id) async {
    final route = fbInstance.collection('inventoryTest');
    await route.doc(id).update({
      'isCollected': true,
    });
  }

  /// Returns all collected items.
  /// Items stuff
  @override
  Future<List<Item>> getCheckedItems() async {
    // TODO: might have bugs.
    final ref = fbInstance.collection('inventoryTest');
    return ref
        .where('isCollected', isEqualTo: false)
        .get()
        .then((res) => _createItemListFromInventory(res.docs));
  }

  /// Returns Item list from firebase json data of all items.
  /// items stuff.
  Future<List<Item>> _createItemListFromInventory(
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
