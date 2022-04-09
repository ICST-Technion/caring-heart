import '../pickup_report.dart';

abstract class ReportServiceI {
  Future<void> setReport(PickupReport report);

  Future<PickupReport> getReport(String itemID);
}
