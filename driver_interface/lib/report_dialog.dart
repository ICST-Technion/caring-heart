import 'dart:collection';

import 'package:driver_interface/report_service.dart';
import 'package:flutter/material.dart';
import 'package:item_spec/pickup_point.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

List<String> _searchContains(final String query, final List<String> items) {
  return items.where((ii) => ii.contains(query.toLowerCase())).toList();
}

class ReportDialog extends StatefulWidget {
  final PickupPoint pickupPoint;
  final List<String> inventoryItems;
  late LinkedHashMap<String, bool> inventoryItemsSelection;
  final reportService = getFirebaseReportService();
  String comments = '';
  ReportDialog(
      {Key? key, required this.pickupPoint, required this.inventoryItems})
      : super(key: key) {
    final category = pickupPoint.item.category;
    final initialItems = _searchContains(category, inventoryItems);
    inventoryItemsSelection =
        LinkedHashMap.fromEntries(initialItems.map((ii) => MapEntry(ii, true)));
  }

  @override
  _ReportDialogState createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  @override
  Widget build(BuildContext context) {
    final autoComplete = TypeAheadField(
        textFieldConfiguration: const TextFieldConfiguration(
            autofocus: true,
            decoration: InputDecoration(
                labelText: 'חפש פריט', icon: Icon(Icons.add_circle_outline))),
        suggestionsCallback: (String suggest) {
          if (suggest.isEmpty) {
            return widget.inventoryItems;
          }
          return _searchContains(suggest, widget.inventoryItems);
        },
        itemBuilder: (context, String item) => ListTile(
              title: Text(item),
            ),
        onSuggestionSelected: (String item) {
          setState(() {
            widget.inventoryItemsSelection[item] = true;
          });
        });
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
    const text = Text(
      'בחר פריטים:',
      style: TextStyle(fontSize: 16),
      textAlign: TextAlign.right,
    );
    final List<Widget> widgets = [commentsInput, autoComplete];
    widgets.addAll(_itemsCheckboxes(widget.inventoryItemsSelection));

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
                final collectedItems = widget.inventoryItemsSelection.entries
                    .where((entry) => entry.value == true)
                    .map((entry) => entry.key)
                    .toList();
                final report = PickupReport.collected(
                    itemID: widget.pickupPoint.item.id,
                    comments: widget.comments,
                    collectedItems: collectedItems);

                await widget.reportService.setReport(report);
                Navigator.of(context).pop();
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
