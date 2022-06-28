import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:nivapp/format_date.dart';
import 'package:nivapp/mock_definitions.mocks.dart';
import 'package:nivapp/route_planner/date_utility.dart';
import 'package:nivapp/services/routes_service.dart';
import 'package:test/test.dart';

void main() {
  group('RouteService', () {
    test(
        'should not remove date field in database on addRouteByItemList(aDate) where aDate already exists',
        () async {
      final fakeFb = FakeFirebaseFirestore();
      var collection = fakeFb.collection('routesTest');
      final date = DateTime(2020, 1, 1);
      DateTime start = DateTime.parse('2020-01-01 10:00:00Z');
      DateTime end = DateTime.parse('2020-01-01 10:30:00Z');
      final dateRange = MyDateTimeRange(start: start, end: end);
      await collection.add({
        'date': formatDate(date),
        'items': [
          {'itemID': 'id', 'time': formatTimeRange(dateRange)}
        ]
      });

      final inventoryMock = MockInventoryServiceI();
      final pp = MockPickupPoint();

      when(pp.pickupTime).thenReturn(dateRange);
      final item = MockItem();
      when(item.id).thenReturn('id');
      when(pp.item).thenReturn(item);

      final inventory = RoutesService(inventoryMock, fakeFb, 'routesTest');
      await inventory.addRouteByItemList([pp], date);
      final updatedRoute = (await collection.get()).docs[0].data();
      expect(updatedRoute.containsKey('date'), true);
    });
  });
}
