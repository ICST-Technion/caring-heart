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
      final addedItem = await fakeFb.collection('inventoryTest').add(itemJson);

      final inventory = InventoryService(fakeFb, 'inventoryTest');
      var actual = await inventory.getItemByID(addedItem.id);
      var item = Item.fromJson(addedItem.id, itemJson);
      expect(actual, equals(item));
    });

    // TODO: this is a new test to be checked. Currently not working.
    // test('item can be marked as checked', () async {
    //   final fakeFb = FakeFirebaseFirestore();
    //   final inventory = InventoryService(fakeFb);
    //   var itemJson1 = getItem();
    //   var itemJson2 = getItem();

    //   final addedItem1 = await fakeFb.collection('inverntory').add(itemJson1);
    //   final addedItem2 = await fakeFb.collection('inverntory').add(itemJson2);

    //   List<Item> checkedList = await inventory.getCheckedItems();

    //   expect(checkedList, equals([Item.fromJson(addedItem2.id, itemJson2)]));
    // });
  });
}
