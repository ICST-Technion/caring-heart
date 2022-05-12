import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:mockito/mockito.dart';
import 'package:nivapp/format_date.dart';
// import 'cat.mocks.dart';
import 'package:nivapp/item_spec.dart';
import 'package:nivapp/pickup_point.dart';
import 'package:nivapp/services/auth_service_i.dart';
import 'package:nivapp/services/init_service.dart';
// import 'package:nivapp/offline_mock_module.mocks.dart';
import 'package:nivapp/services/inventory_service_i.dart';
import 'package:nivapp/services/report_service_i.dart';
import 'package:nivapp/services/routes_service_i.dart';

import 'driver_interface/extract_phone_numbers.dart';
import 'mock_definitions.mocks.dart';

MockInventoryServiceI getInventoryMock(List<Item> items) {
  assert(items.every((item) => !item.isCollected && item.isChecked));

  final mock = MockInventoryServiceI();
  when(mock.getCheckedItems()).thenAnswer((_) async => items);
  when(mock.getItemByID(any)).thenAnswer((i) async =>
      items.firstWhere((item) => item.id == i.positionalArguments[0]));
  return mock;
}

/// creates a mock for RoutesServiceI that returns the same pickpup points for
/// all dates, initialized with [initialPickupPoints].
MockRoutesServiceI getSingleDayRoutesMock(
    List<PickupPoint> initialPickupPoints) {
  var points = initialPickupPoints;
  final mock = MockRoutesServiceI();
  when(mock.getItems(getDay: anyNamed("getDay")))
      .thenAnswer((_) async => points);
  when(mock.addRouteByItemList(any, any)).thenAnswer(
      (realInvocation) async => points = realInvocation.positionalArguments[0]);
  return mock;
}

MockAuthServiceI getAuthSignedInMock() {
  final mock = MockAuthServiceI();
  when(mock.name).thenReturn('mock_name');
  when(mock.uid).thenReturn('mock_uid');
  when(mock.userEmail).thenReturn('mock@mail.com');
  when(mock.isUserRemembered()).thenAnswer((_) async => true);
  when(mock.signInWithEmailPassword(any, any)).thenAnswer((_) async => null);
  return mock;
}

DateTime getDateMock(int i) => DateTime(2030).add(Duration(hours: 12 * i));

Item getItemMock(int i) => Item(
    address: 'long long address$i',
    floor: 'floor$i',
    apartment: 'apartment$i',
    neighborhood: 'neighborhood$i',
    city: 'long city$i',
    comments: 'comments$i',
    date: getDateMock(i),
    description: 'description$i',
    email: '$i@mail.com',
    isChecked: true,
    isCollected: false,
    name: 'like a very long name',
    id: i.toString(),
    phone: 'name$i - 0${500000000 + i}, name${i + 1} - 0${500000000 + i + 1}');

Injector OfflineMockModule() {
  final injector = Injector();

  injector.map<AuthServiceI>((i) => getAuthSignedInMock(), isSingleton: true);
  injector.map<InitService>((i) => MockInitService(), isSingleton: true);

  final inventoryItems = Iterable<int>.generate(10).map(getItemMock).toList();

  final pickupPoints = Iterable<int>.generate(10)
      .map((i) => PickupPoint(
          item: getItemMock(i), pickupTime: formatDate(getDateMock(i))))
      .toList();

  injector.map<InventoryServiceI>((i) => getInventoryMock(inventoryItems),
      isSingleton: true);
  injector.map<RoutesServiceI>((i) => getSingleDayRoutesMock(pickupPoints),
      isSingleton: true);
  injector.map<ReportServiceI>((i) => MockReportServiceI(), isSingleton: true);
  injector.map<ExtractPhoneNumbers>((i) => ExtractPhoneNumbers());

  return injector;
}
