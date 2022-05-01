import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:nivapp/format_date.dart';
import 'package:nivapp/item_spec.dart';
import 'package:nivapp/mock_definitions.mocks.dart';
import 'package:nivapp/services/inventory_service.dart';
import 'package:nivapp/services/routes_service.dart';
import 'package:test/test.dart';

import 'inventory_service_test.dart';

void main() {
  group('RouteService', () {
    test(
        'should not remove date field in database on addRouteByItemList(aDate) where aDate already exists',
        () async {
      final fakeFb = FakeFirebaseFirestore();
      var collection = fakeFb.collection('routesTest');
      final date = DateTime(2020, 1, 1);
      await collection.add({
        'date': formatDate(date),
        'items:': [
          {'itemID': 'id', 'time': '8:00'}
        ]
      });
      final inventoryMock = MockInventoryServiceI();
      final pp = MockPickupPoint();
      when(pp.pickupTime).thenReturn('8:00');
      final item = MockItem();
      when(item.id).thenReturn('id');
      when(pp.item).thenReturn(item);

      final inventory = RoutesService(inventoryMock, fakeFb);
      await inventory.addRouteByItemList([pp], date);
      final updatedRoute = (await collection.get()).docs[0].data();
      expect(updatedRoute.containsKey('date'), true);
    });
  });
}
