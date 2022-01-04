import 'package:date_format/date_format.dart';

import 'package:item_spec/item_spec.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemService {
  ItemService();

  Future<List<Item>> getItems() async {
    final route = FirebaseFirestore.instance.collection('routesTest');
    return route
        .where('date',
            isEqualTo: formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd]))
        .get()
        .then((res) => createItemListFromRoute(res.docs));
  }

  Future<List<Item>> createItemListFromRoute(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    List<Item> items = [];
    for (var doc in docs) {
      final List currentItems = doc.data()['items'];
      for (var item in currentItems) {
        var data = await getItemByID(item['itemID']);
        if (!data['isCollected']) {
          items.add(Item.fromJson(item['itemID'], data.data(), item['time']));
        }
      }
    }
    return items;
  }

  getItemByID(id) {
    final inventory = FirebaseFirestore.instance.collection('inventoryTest');
    return inventory.doc(id).get();
  }

  Future<void> collectItem(id) async {
    final route = FirebaseFirestore.instance.collection('inventoryTest');
    await route.doc(id).update({
      'isCollected': true,
    });
  }
}
