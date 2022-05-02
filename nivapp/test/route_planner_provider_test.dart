// import 'package:mockito/mockito.dart';
// import 'package:nivapp/driver_interface/driver_interface_provider.dart';
// import 'package:nivapp/item_spec.dart';
// import 'package:nivapp/mock_definitions.mocks.dart';
// import 'package:nivapp/pickup_point.dart';
// import 'package:nivapp/route_planner/route_planner.dart';
// import 'package:nivapp/route_planner/route_planner_provider.dart';
// import 'package:test/test.dart';

// class InitPlannerProviderResult {
//   final RoutePlannerProvider provider;
//   final MockRoutesServiceI routeMock;
//   final MockMyFunction listenerMock;

//   InitPlannerProviderResult(this.provider, this.routeMock, this.listenerMock);
// }

// InitPlannerProviderResult initPlannerProvider(List<Item> _itemList) {
//   final routeMock = MockRoutesServiceI();
//   final provider = RoutePlannerProvider(routeMock, itemList: _itemList);
//   final listenerMock = MockMyFunction();
//   provider.addListener(listenerMock);
//   return InitPlannerProviderResult(provider, routeMock, listenerMock);
// }

// void main() {
//   group('RoutePlannerProvider', () {
//     test('should be intialized with all items in itemList', () async {
//       List<Item> itemList = List.generate(10, (index) => MockItem());
//       final i = initPlannerProvider(itemList);

//       expect(i.provider.selectedItems, isEmpty);
//       expect(i.provider.itemList, equals(itemList));
//     });
//     test(
//         'Select/Remove item from selected items. '
//         'Should add the item to SelectedItems and delete it if it\'s already there',
//         () {
//       var mockItem1 = MockItem();
//       var mockItem2 = MockItem();
//       List<Item> itemList = [mockItem1, mockItem2];
//       final i = initPlannerProvider(itemList);

//       i.provider.SelectItemAt(itemList.indexOf(mockItem1));
//       i.provider.SelectItemAt(itemList.indexOf(mockItem2));

//       verify(i.listenerMock());
//       expect(
//           i.provider.selectedItems,
//           equals([
//             PickupPoint(item: mockItem1, pickupTime: ""),
//             PickupPoint(item: mockItem2, pickupTime: "")
//           ]));

//       i.provider.SelectItemAt(itemList.indexOf(mockItem2));

//       verify(i.listenerMock());
//       expect(i.provider.selectedItems,
//           equals([PickupPoint(item: mockItem1, pickupTime: "")]));
//     });

//   });
// }
