import 'package:mockito/mockito.dart';
import 'package:nivapp/driver_interface/driver_interface_provider.dart';
import 'package:nivapp/mock_definitions.mocks.dart';
import 'package:nivapp/pickup_point.dart';
import 'package:nivapp/pickup_report.dart';
import 'package:nivapp/services/report_service_i.dart';
import 'package:test/test.dart';

class InitDriverProviderResult {
  final DriverInterfaceProvider provider;
  final MockReportServiceI reportMock;
  final MockMyFunction listenerMock;

  InitDriverProviderResult(this.provider, this.reportMock, this.listenerMock);
}

InitDriverProviderResult initDriverProvider(List<PickupPoint> route) {
  final reportMock = MockReportServiceI();
  final provider = DriverInterfaceProvider(route, reportMock);
  final listenerMock = MockMyFunction();
  provider.addListener(listenerMock);
  return InitDriverProviderResult(provider, reportMock, listenerMock);
}

void main() {
  group('DriverInterfaceProvider', () {
    test('should be intialized with all points in uncollectedPoints', () async {
      List<PickupPoint> route = List.generate(10, (index) => MockPickupPoint());
      final i = initDriverProvider(route);

      expect(i.provider.collectedPickupPoints, isEmpty);
      expect(i.provider.uncollectedPickupPoints, equals(route));
    });
    test('moves point to collectedPickupPoints on acceptItem()/rejectItem()',
        () async {
      var mockPickupPoint = MockPickupPoint();
      List<PickupPoint> route = [mockPickupPoint];
      for (var iter in Iterable<int>.generate(2)) {
        final i = initDriverProvider(route);
        if (iter == 0) {
          await i.provider.acceptItem(mockPickupPoint);
        } else {
          await i.provider.rejectItem(mockPickupPoint);
        }

        verify(i.listenerMock());

        expect(i.provider.collectedPickupPoints, equals([mockPickupPoint]));
      }
    });
    test('activateItem() reports uncollected', () async {
      var mockPickupPoint = MockPickupPoint();
      var mockItem = MockItem();
      when(mockItem.id).thenReturn('id-1');
      when(mockPickupPoint.item).thenReturn(mockItem);
      List<PickupPoint> route = [mockPickupPoint];
      final i = initDriverProvider(route);
      await i.provider.activateItem(mockPickupPoint);
      verify(i.reportMock.setReport(any));
    });
    test(
        'moves point back to uncollected if activateItem() after acceptItem()/rejectItem()',
        () async {
      var mockPickupPoint = MockPickupPoint();
      var mockItem = MockItem();
      when(mockItem.id).thenReturn('id-1');
      when(mockPickupPoint.item).thenReturn(mockItem);
      List<PickupPoint> route = [mockPickupPoint];
      final i = initDriverProvider(route);
      await i.provider.acceptItem(mockPickupPoint);
      await i.provider.activateItem(mockPickupPoint);

      verify(i.listenerMock()).called(2);

      expect(i.provider.collectedPickupPoints, isEmpty);
      expect(i.provider.uncollectedPickupPoints, [mockPickupPoint]);
    });
  });
}
