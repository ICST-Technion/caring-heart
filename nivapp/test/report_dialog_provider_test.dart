import 'package:mockito/mockito.dart';
import 'package:nivapp/driver_interface/driver_interface_provider.dart';
import 'package:nivapp/driver_interface/report_dialog.dart';
import 'package:nivapp/mock_definitions.mocks.dart';
import 'package:nivapp/pickup_point.dart';
import 'package:nivapp/pickup_report.dart';
import 'package:nivapp/services/report_service_i.dart';
import 'package:nivapp/driver_interface/report_dialog_provider.dart';
import 'package:test/test.dart';
import 'package:nivapp/item_spec.dart';

class InitDriverProviderResult {
  final DriverInterfaceProvider provider;
  final MockReportServiceI reportMock;
  final MockMyFunction listenerMock;

  InitDriverProviderResult(this.provider, this.reportMock, this.listenerMock);
}

void main() {
  group("report_dialog_provider tests", () {
    test("Should initialize allItems to the item in the description.", () {
      PickupPoint mpp = MockPickupPoint();
      ReportDialogType rdt = ReportDialogType.collect(["1", "2", "3"]);
      ReportServiceI rs = MockReportServiceI();
      Item item = MockItem();

      when(item.description).thenReturn("3");
      when(mpp.item).thenReturn(item);
      ReportDialogProvider rdp = ReportDialogProvider(mpp, rdt, rs);
      expect(rdp.allItems, ["3"]);
      // now the test part.
    });
    test("Should initialize allItems to the multiple items in the description.",
        () {
      // fails
      PickupPoint mpp = MockPickupPoint();
      ReportDialogType rdt = ReportDialogType.collect(["1", "2", "3"]);
      ReportServiceI rs = MockReportServiceI();
      Item item = MockItem();

      when(item.description).thenReturn("2, 3");
      when(mpp.item).thenReturn(item);
      ReportDialogProvider rdp = ReportDialogProvider(mpp, rdt, rs);
      expect(rdp.allItems, ["2", "3"]);
      // now the test part.
    });
    test(
        "Should initialize allItems with items where the first word in the item is in the description",
        () {
      // fails
      PickupPoint mpp = MockPickupPoint();
      ReportDialogType rdt = ReportDialogType.collect(["a1 a2", "b1, b2"]);
      ReportServiceI rs = MockReportServiceI();
      Item item = MockItem();

      when(item.description).thenReturn("a1, b2");
      when(mpp.item).thenReturn(item);
      ReportDialogProvider rdp = ReportDialogProvider(mpp, rdt, rs);
      expect(rdp.allItems, ["a1 a2"]);
      // now the test part.
    });
  });
}
