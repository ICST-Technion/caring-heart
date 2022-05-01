import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:nivapp/driver_interface/report_dialog.dart';

import '../pickup_point.dart';
import '../pickup_report.dart';
import '../services/report_service_i.dart';

List<String> _searchContains(final String query, final List<String> items) {
  return items.where((ii) => query.toLowerCase().contains(ii)).toList();
}

class ReportDialogProvider with ChangeNotifier {
  final PickupPoint pickupPoint;
  final ReportDialogType type;
  LinkedHashMap<String, bool>? _inventoryItemsSelection;


  UnmodifiableMapView<String, bool>? get inventoryItemsSelection {
    if (_inventoryItemsSelection == null) return null;
    return UnmodifiableMapView(_inventoryItemsSelection!);
  }

  List<String>? get allItems => _inventoryItemsSelection?.keys.toList();
  final ReportServiceI _reportService;
  String comments = '';

  ReportDialogProvider(this.pickupPoint, this.type, this._reportService) { // TODO: check this.
    final description = pickupPoint.item.description;
    if (type.isCollect()) {
      final initialItems = _searchContains(description, type.inventoryItems!);
      _inventoryItemsSelection = LinkedHashMap.fromEntries(
          initialItems.map((ii) => MapEntry(ii, true)));
    }
  }

  List<String> getItemsSuggestion(String suggest) {
    if (suggest.isEmpty) {
      return type.inventoryItems!;
    }
    return _searchContains(suggest, type.inventoryItems!);
  }

  void onSuggestionSelected(String item) {
    _inventoryItemsSelection![item] = true;
    notifyListeners();
  }

  Future<void> reportCurrentSelectedItems() async {
    late PickupReport report;
    if (type.isCollect()) {
      final collectedItems = _inventoryItemsSelection!.entries
          .where((entry) => entry.value == true)
          .map((entry) => entry.key)
          .toList();
      report = PickupReport.collected(
          itemID: pickupPoint.item.id,
          comments: comments,
          collectedItems: collectedItems);
    } else {
      report = PickupReport.canceled(
          itemID: pickupPoint.item.id, comments: comments);
    }

    await _reportService.setReport(report);
  }

  void setComments(String newValue) {
    comments = newValue;
    notifyListeners();
  }

  void changeItemSelection(String item, bool? isSelected) {
    if (isSelected != null) {
      _inventoryItemsSelection![item] = isSelected;
    }
    notifyListeners();
  }
}
