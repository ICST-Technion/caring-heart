import 'package:date_format/date_format.dart';

import 'item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemService {
  ItemService();

  Future<List<Item>> getItems() async {
    final route = FirebaseFirestore.instance.collection('routesTest');
    return route
        .where('date', isEqualTo: formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd]))
        .get()
        .then((res) => createItemListFromRoute(res.docs));
  }

  Future<List<Item>> createItemListFromRoute (
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    List<Item> items = [];
    for (var doc in docs) {
      final List currentItems = doc.data()['items'];
      for (var item in currentItems) {
        var data = await getItemByID(item['itemID']);
        items.add(Item.fromJson(doc.id, data.data(), item['time']));
      }
    }
    return items;
  }

  getItemByID(id) {
    final inventory = FirebaseFirestore.instance.collection('inventoryTest');
    return inventory.doc(id).get();
  }
}
