import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:nivapp/item_spec.dart';
import 'package:nivapp/services/inventory_service.dart';
import 'package:test/test.dart';

Map<String, dynamic> getItem(
        {address = 'adresss',
        floor = '0',
        apartment = 'apartment',
        neighborhood = 'neighborhood',
        city = 'city',
        comments = 'comments',
        date = DateTime.now,
        description = 'description',
        email = 'email@email.com',
        isChecked = true,
        isCollected = false,
        name = 'name',
        phone = '0544444444'}) =>
    {
      'address': address,
      'floor': floor,
      'apartment': apartment,
      'neighborhood': neighborhood,
      'city': city,
      'comments': comments,
      'date': date(),
      'description': description,
      'email': email,
      'isChecked': isChecked,
      'isCollected': isCollected,
      'name': name,
      'phone': phone
    };
void main() {
  group('InventoryService', () {
    test('should return single item by id after adding it to firebase',
        () async {
      final fakeFb = FakeFirebaseFirestore();
      var itemJson = getItem();
      final addedItem = await fakeFb.collection('inventory').add(itemJson);

      final inventory = InventoryService(fakeFb);
      var actual = await inventory.getItemByID(addedItem.id);
      var item = Item.fromJson(addedItem.id, itemJson);
      expect(actual, equals(item));
    });
  });
}
