import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nivapp/services/report_service_i.dart';

import '../pickup_report.dart';

/// Handles reports of collected or uncollected PickupItems
class ReportService implements ReportServiceI {
  final String collectionPath;

  ReportService(this.collectionPath);

  get _collection => FirebaseFirestore.instance.collection(collectionPath);

  Future<void> _uploadReport(
          Map<String, dynamic> reportJson, String reportId) =>
      _collection.doc(reportId).set(reportJson);

  Future<Map<String, dynamic>> _getReportById(String itemID) async {
    final doc = await _collection.doc(itemID).get();
    return doc.data()!;
  }

  @override
  Future<void> setReport(PickupReport report) {
    return _uploadReport(report.toJson(), report.itemID);
  }

  @override
  Future<PickupReport> getReport(String itemID) async {
    final reportJson = await _getReportById(itemID);
    return PickupReport.fromJson(reportJson, itemID);
  }
}
