import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nivapp/driver_interface/report_dialog.dart';

import '../pickup_point.dart';
import '../pickup_report.dart';
import '../services/report_service_i.dart';

class NonNegativeCounter {
  final int value;
  NonNegativeCounter({
    required this.value,
  });
  NonNegativeCounter._(this.value);
  factory NonNegativeCounter.zero() => NonNegativeCounter._(0);
  factory NonNegativeCounter.unsafe(int value) {
    assert(value >= 1);
    return NonNegativeCounter._(value);
  }
  NonNegativeCounter inc() {
    return NonNegativeCounter._(value + 1);
  }

  NonNegativeCounter dec() {
    return NonNegativeCounter._(max(value - 1, 0));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NonNegativeCounter && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

List<String> _searchContains(final String query, final List<String> items) {
  return items
      .where((item) =>
          query.toLowerCase().contains(item) ||
          query.toLowerCase().contains(item.split(' ')[0]))
      .toList();
}

class ReportDialogProvider with ChangeNotifier {
  final PickupPoint pickupPoint;
  final ReportDialogType type;
  LinkedHashMap<String, NonNegativeCounter>? _inventoryItemsCount;
  List<MapEntry<String, NonNegativeCounter>> get _nonZeroCountItems =>
      _inventoryItemsCount!.entries
          .where((entry) => entry.value.value > 0)
          .toList();
  bool get disableAccept => type.isCollect() && _nonZeroCountItems.isEmpty;

  UnmodifiableMapView<String, NonNegativeCounter>? get inventoryItemsCount {
    if (_inventoryItemsCount == null) return null;
    return UnmodifiableMapView(_inventoryItemsCount!);
  }

  List<String>? get allItems => _inventoryItemsCount?.keys.toList();
  final ReportServiceI _reportService;
  String comments = '';

  ReportDialogProvider(this.pickupPoint, this.type, this._reportService) {
    final description = pickupPoint.item.description;
    if (type.isCollect()) {
      final initialItems = _searchContains(description, type.inventoryItems!);
      _inventoryItemsCount = LinkedHashMap.fromEntries(
          initialItems.map((ii) => MapEntry(ii, NonNegativeCounter.zero())));
    }
  }

  List<String> getItemsSuggestion(String suggest) {
    if (suggest.isEmpty) {
      return type.inventoryItems!;
    }
    return _searchContains(suggest, type.inventoryItems!);
  }

  void onSuggestionSelected(String item) {
    _inventoryItemsCount![item] = NonNegativeCounter.zero().inc();
    notifyListeners();
  }

  Future<void> reportCurrentSelectedItems() async {
    late PickupReport report;
    if (type.isCollect()) {
      report = PickupReport.collected(
          itemID: pickupPoint.item.id,
          comments: comments,
          collectedItems: Map.fromEntries(_nonZeroCountItems
              .map((entry) => MapEntry(entry.key, entry.value.value))));
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

  void addOneToItem(String item) {
    _inventoryItemsCount![item] = _inventoryItemsCount![item]!.inc();
    notifyListeners();
  }

  void substractOneFromItem(String item) {
    _inventoryItemsCount![item] = _inventoryItemsCount![item]!.dec();
    notifyListeners();
  }
}
