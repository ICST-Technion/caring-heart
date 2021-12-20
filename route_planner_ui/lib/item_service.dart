import 'item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemService {
  ItemService();

  Future<List<Item>> getCheckedItems() async {
    final ref = FirebaseFirestore.instance.collection('inventoryTest');
    return ref
        .where('isChecked', isEqualTo: true)
        .get()
        .then((res) => createItemListFromInventory(res.docs));
  }

  Future<List<Item>> createItemListFromInventory (
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    List<Item> items = [];
    for (var doc in docs) {
      items.add(Item.fromJson(doc.id, doc.data()));
    }
    return items;
  }
}
