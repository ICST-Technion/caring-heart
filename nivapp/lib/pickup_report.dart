// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'dart:collection';

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
  late final Map<String, int>? collectedItems;
  PickupReport({
    required this.itemID,
    required this.status,
    this.comments,
    this.collectedItems,
  });

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

  factory PickupReport.canceled(
      {required String itemID, required String comments}) {
    return PickupReport._(
        itemID: itemID,
        status: PickupReportStatus.canceled,
        comments: comments,
        collectedItems: null);
  }

  factory PickupReport.collected(
      {required String itemID,
      required String comments,
      required Map<String, int> collectedItems}) {
    return PickupReport._(
        itemID: itemID,
        status: PickupReportStatus.collected,
        comments: comments,
        collectedItems: collectedItems);
  }

  // without ItemID!, itemID should be the key of the json
  Map<String, dynamic> toJson() {
    Map<String, dynamic> res = {
      'status': status.toShortString(),
    };
    if (status != PickupReportStatus.uncollected) {
      res['comments'] = comments!;
    }
    if (status == PickupReportStatus.collected) {
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
      assert(json.containsKey('comments'));
      return PickupReport.canceled(itemID: itemID, comments: json['comments']);
    }
    if (status == PickupReportStatus.uncollected) {
      return PickupReport.uncollected(itemID: itemID);
    }

    assert(json.containsKey('comments') && json.containsKey('collectedItems'));

    return PickupReport.collected(
        itemID: itemID,
        comments: json['comments'],
        collectedItems: (json['collectedItems'] as Map<String, int>));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PickupReport &&
        other.itemID == itemID &&
        other.status == status &&
        other.comments == comments &&
        mapEquals(other.collectedItems, collectedItems);
  }

  @override
  int get hashCode {
    return itemID.hashCode ^
        status.hashCode ^
        comments.hashCode ^
        collectedItems.toString().hashCode;
  }
}
