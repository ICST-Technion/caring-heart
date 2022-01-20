import 'dart:collection';

import 'package:driver_interface/report_service.dart';
import 'package:flutter/material.dart';
import 'package:item_spec/pickup_point.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

List<String> _searchContains(final String query, final List<String> items) {
  return items.where((ii) => ii.contains(query.toLowerCase())).toList();
}

class ReportDialogType {
  late final PickupReportStatus status;
  late final List<String>? inventoryItems;
  ReportDialogType._(this.status, this.inventoryItems);
  factory ReportDialogType.collect(List<String> inventoryItems) {
    return ReportDialogType._(PickupReportStatus.collected, inventoryItems);
  }
  factory ReportDialogType.cancel() {
    return ReportDialogType._(PickupReportStatus.canceled, null);
  }
  bool isCollect() => status == PickupReportStatus.collected;
  bool isCancel() => status == PickupReportStatus.canceled;
}

class ReportDialog extends StatefulWidget {
  final PickupPoint pickupPoint;
  // final List<String> inventoryItems;
  final ReportDialogType type;
  LinkedHashMap<String, bool>? inventoryItemsSelection;
  final reportService = getFirebaseReportService();
  String comments = '';
  ReportDialog({Key? key, required this.pickupPoint, required this.type})
      : super(key: key) {
    final description = pickupPoint.item.description;
    if (type.isCollect()) {
      final initialItems = _searchContains(description, type.inventoryItems!);
      inventoryItemsSelection = LinkedHashMap.fromEntries(
          initialItems.map((ii) => MapEntry(ii, true)));
    }
  }

  @override
  _ReportDialogState createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  @override
  Widget build(BuildContext context) {
    final commentsInput = TextField(
      onChanged: (value) {
        widget.comments = value;
      },
      keyboardType: TextInputType.multiline,
      decoration: const InputDecoration(
        labelText: 'הערות',
      ),
      maxLines: null,
    );

    final List<Widget> widgets = [commentsInput];
    if (widget.type.isCollect()) {
      final autoComplete = TypeAheadField(
          textFieldConfiguration: const TextFieldConfiguration(
              autofocus: true,
              decoration: InputDecoration(
                  labelText: 'חפש פריט', icon: Icon(Icons.add_circle_outline))),
          suggestionsCallback: (String suggest) {
            if (suggest.isEmpty) {
              return widget.type.inventoryItems!;
            }
            return _searchContains(suggest, widget.type.inventoryItems!);
          },
          itemBuilder: (context, String item) => ListTile(
                title: Text(item),
              ),
          onSuggestionSelected: (String item) {
            setState(() {
              widget.inventoryItemsSelection![item] = true;
            });
          });
      widgets.add(autoComplete);
      widgets.addAll(_itemsCheckboxes(widget.inventoryItemsSelection!));
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: Text('דיווח איסוף ב' + widget.pickupPoint.item.address),
        scrollable: true,
        content: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: widgets,
        ),
        actions: [
          TextButton(
              onPressed: () async {
                late PickupReport report;
                if (widget.type.isCollect()) {
                  final collectedItems = widget.inventoryItemsSelection!.entries
                      .where((entry) => entry.value == true)
                      .map((entry) => entry.key)
                      .toList();
                  report = PickupReport.collected(
                      itemID: widget.pickupPoint.item.id,
                      comments: widget.comments,
                      collectedItems: collectedItems);
                } else {
                  report = PickupReport.canceled(
                      itemID: widget.pickupPoint.item.id,
                      comments: widget.comments);
                }

                await widget.reportService.setReport(report);
                Navigator.of(context).pop(true);
              },
              child: const Text('אשר'))
        ],
      ),
    );
  }

  List<Widget> _itemsCheckboxes(Map<String, bool> selections) {
    return selections.entries
        .map((itemEntry) => CheckboxListTile(
              title: Text(itemEntry.key),
              value: itemEntry.value,
              onChanged: (bool? value) => {
                setState(() {
                  if (value != null) {
                    selections[itemEntry.key] = value;
                  }
                })
              },
            ))
        .toList();
  }
}
