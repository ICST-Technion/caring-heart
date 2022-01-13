import 'package:cloud_firestore/cloud_firestore.dart';

enum PickupReportStatus { uncollected, collected, canceled }

extension _Shorten on PickupReportStatus {
  String toShortString() {
    return toString().split('.')[1];
  }
}

class PickupReport {
  late final String itemID;
  late final PickupReportStatus status;
  late final String? comments;
  late final List<String>? collectedItems;

  PickupReport._(
      {required this.itemID,
      required this.status,
      required this.comments,
      required this.collectedItems});

  factory PickupReport.uncollected({required String itemID}) {
    return PickupReport._(
        itemID: itemID,
        status: PickupReportStatus.uncollected,
        comments: null,
        collectedItems: null);
  }

  factory PickupReport.canceled({required String itemID}) {
    return PickupReport._(
        itemID: itemID,
        status: PickupReportStatus.canceled,
        comments: null,
        collectedItems: null);
  }

  factory PickupReport.collected(
      {required String itemID,
      required String comments,
      required List<String> collectedItems}) {
    return PickupReport._(
        itemID: itemID,
        status: PickupReportStatus.collected,
        comments: comments,
        collectedItems: collectedItems);
  }

  // without ItemID!, itemID should be the key of the json
  Map<String, dynamic> toJson() {
    Map<String, dynamic> res = {
      // 'itemID': itemID,
      'status': status.toShortString(),
    };
    if (status == PickupReportStatus.collected) {
      res['comments'] = comments!;
      res['collectedItems'] = collectedItems!;
    }
    return res;
  }

  factory PickupReport.fromJson(Map<String, dynamic> json, String itemID) {
    // itemID is the key, and is not inside the object
    assert(!json.containsKey('itemID'));

    assert(json.containsKey('status'));
    final legalStatuses =
        PickupReportStatus.values.map((s) => s.toShortString());
    final String stringStatus = json['status'];
    assert(legalStatuses.contains(stringStatus));

    final PickupReportStatus status = PickupReportStatus.values
        .firstWhere((s) => stringStatus == s.toShortString());

    if (status == PickupReportStatus.canceled) {
      return PickupReport.canceled(itemID: itemID);
    }
    if (status == PickupReportStatus.uncollected) {
      return PickupReport.uncollected(itemID: itemID);
    }

    assert(json.containsKey('comments') && json.containsKey('collectedItems'));

    return PickupReport.collected(
        itemID: itemID,
        comments: json['comments'],
        collectedItems: json['collectedItems']);
  }
}

class ReportService {
  final Future<void> Function(Map<String, dynamic> reportJson, String itemID)
      _uploadReport;

  final Future<Map<String, dynamic>> Function(String itemID) _getReportById;

  ReportService(this._uploadReport, this._getReportById);

  Future<void> setReport(PickupReport report) {
    return _uploadReport(report.toJson(), report.itemID);
  }

  Future<PickupReport> getReport(String itemID) async {
    final reportJson = await _getReportById(itemID);
    return PickupReport.fromJson(reportJson, itemID);
  }
}

ReportService getFirebaseReportService(
    {String reportCollectionName = 'reportsTest'}) {
  final collection =
      FirebaseFirestore.instance.collection(reportCollectionName);
  // ignore: prefer_function_declarations_over_variables, unused_local_variable
  final uploadReport = (Map<String, dynamic> reportJson, String reportId) =>
      collection.doc(reportId).set(reportJson);
  // ignore: prefer_function_declarations_over_variables, unused_local_variable
  final getReportById = (String itemID) async {
    final doc = await collection.doc(itemID).get();
    return doc.data()!;
  };

  return ReportService(uploadReport, getReportById);
}
