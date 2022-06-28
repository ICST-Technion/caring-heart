import 'package:mockito/mockito.dart';
import 'package:nivapp/item_spec.dart';
import 'package:nivapp/mock_definitions.mocks.dart';
import 'package:nivapp/pickup_point.dart';
import 'package:nivapp/route_planner/date_utility.dart';
import 'package:nivapp/route_planner/route_planner_provider.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

class InitPlannerProviderResult {
  final RoutePlannerProvider provider;
  final MockRoutesServiceI routeMock;
  final MockMyFunction listenerMock;

  InitPlannerProviderResult(this.provider, this.routeMock, this.listenerMock);
}

InitPlannerProviderResult initPlannerProvider(List<Item> _itemList) {
  final routeMock = MockRoutesServiceI();
  final provider =
      RoutePlannerProvider(routeMock, itemList: _itemList, pickupPoints: []);
  final listenerMock = MockMyFunction();
  provider.addListener(listenerMock);
  return InitPlannerProviderResult(provider, routeMock, listenerMock);
}

void main() {
  group('RoutePlannerProvider', () {
    test('should be intialized with all items in itemList', () async {
      List<Item> itemList = List.generate(10, (index) => MockItem());
      itemList.forEach((item) => when(item.comments).thenReturn(""));

      final i = initPlannerProvider(itemList);

      List<Tuple2<bool, Item>> modifiedItemList =
          itemList.map((item) => Tuple2(false, item)).toList();
      expect(i.provider.selectedItems, isEmpty);
      expect(i.provider.itemList, equals(modifiedItemList));
    });

    test(
        'Select/Remove item from selected items. '
        'Should add the item to SelectedItems and delete it if it\'s already there',
        () {
      Item mockItem1 = MockItem();
      Item mockItem2 = MockItem();
      List<Item> itemList = [mockItem1, mockItem2];
      itemList.forEach((item) => when(item.comments).thenReturn(""));

      final i = initPlannerProvider(itemList);

      MyDateTimeRange mdtrStub = MyDateTimeRange(
          start: DateTime.parse("2020-07-07"),
          end: DateTime.parse("2020-07-07"));
      PickupPoint mockPickupPoint1 = MockPickupPoint();
      when(mockPickupPoint1.item).thenReturn(mockItem1);
      when(mockPickupPoint1.pickupTime).thenReturn(mdtrStub);
      PickupPoint mockPickupPoint2 = MockPickupPoint();
      when(mockPickupPoint2.item).thenReturn(mockItem2);
      when(mockPickupPoint2.pickupTime).thenReturn(mdtrStub);

      i.provider.addPickupPointToDB(mockPickupPoint1);
      i.provider.addPickupPointToDB(mockPickupPoint2);

      verify(i.listenerMock());
      expect(i.provider.selectedItems,
          equals([mockPickupPoint1, mockPickupPoint2]));

      i.provider.removePickupPointFromDB(mockPickupPoint2);

      verify(i.listenerMock());
      expect(i.provider.selectedItems, equals([mockPickupPoint1]));
    });
  });
}
