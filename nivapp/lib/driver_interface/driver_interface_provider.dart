import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:nivapp/pickup_point.dart';
import 'package:nivapp/services/report_service_i.dart';

import '../pickup_report.dart';

class DriverInterfaceProvider with ChangeNotifier {
  final List<PickupPoint> _todaysRoute;
  final ReportServiceI _reportService;

  late final Map<PickupPoint, PickupReportStatus> pickupPointsStatusMap;

  List<PickupPoint> get collectedPickupPoints => _todaysRoute
      .where(
          (pp) => pickupPointsStatusMap[pp]! != PickupReportStatus.uncollected)
      .toList();

  List<PickupPoint> get uncollectedPickupPoints {
    final pList = _todaysRoute
        .where((pp) =>
            pickupPointsStatusMap[pp]! == PickupReportStatus.uncollected)
        .toList();
    pList.sort((PickupPoint p1, PickupPoint p2) =>
        p1.pickupTime!.start.compareTo(p2.pickupTime!.start));
    return pList;
  }

  DriverInterfaceProvider(this._todaysRoute, this._reportService) {
    pickupPointsStatusMap = {
      for (var item in _todaysRoute) item: PickupReportStatus.uncollected
    };
  }

  Future<void> acceptItem(PickupPoint pp) async {
    pickupPointsStatusMap[pp] = PickupReportStatus.collected;
    notifyListeners();
  }

  Future<void> rejectItem(PickupPoint pp) async {
    pickupPointsStatusMap[pp] = PickupReportStatus.canceled;
    notifyListeners();
  }

  Future<void> activateItem(PickupPoint pp) async {
    pickupPointsStatusMap[pp] = PickupReportStatus.uncollected;
    notifyListeners();
    await _reportService
        .setReport(PickupReport.uncollected(itemID: pp.item.id));
  }
}
