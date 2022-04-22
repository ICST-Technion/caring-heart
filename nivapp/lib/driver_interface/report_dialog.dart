import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:nivapp/driver_interface/report_dialog_provider.dart';
import 'package:provider/provider.dart';

import '../pickup_report.dart';

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
  const ReportDialog({Key? key}) : super(key: key);

  @override
  _ReportDialogState createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  ReportDialogProvider getProvider(_context, _listen) =>
      Provider.of<ReportDialogProvider>(_context, listen: _listen);

  @override
  Widget build(BuildContext context) {
    final commentsInput = TextField(
      onChanged: getProvider(context, true).setComments,
      keyboardType: TextInputType.multiline,
      decoration: const InputDecoration(
        labelText: 'הערות',
      ),
      maxLines: null,
    );

    final List<Widget> widgets = [commentsInput];
    if (getProvider(context, true).type.isCollect()) {
      final autoComplete = TypeAheadField(
          textFieldConfiguration: const TextFieldConfiguration(
              autofocus: true,
              decoration: InputDecoration(
                  labelText: 'חפש פריט', icon: Icon(Icons.add_circle_outline))),
          suggestionsCallback: getProvider(context, false).getItemsSuggestion,
          itemBuilder: (context, String item) => ListTile(
                title: Text(item),
              ),
          onSuggestionSelected: getProvider(context, false).onSuggestionSelected);
      widgets.add(autoComplete);
      widgets.addAll(_itemsCheckboxes(getProvider(context, true).inventoryItemsSelection!));
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: Text('דיווח איסוף ב' + getProvider(context, true).pickupPoint.item.address),
        scrollable: true,
        content: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: widgets,
        ),
        actions: [
          TextButton(
              onPressed: () async {
                await getProvider(context, false).reportCurrentSelectedItems();
                Navigator.of(context).pop(true);
              },
              child: const Text('אשר'))
        ],
      ),
    );
  }

  List<Widget> _itemsCheckboxes(UnmodifiableMapView<String, bool> selections) {
    return selections.entries
        .map((itemEntry) => CheckboxListTile(
              title: Text(itemEntry.key),
              value: itemEntry.value,
              onChanged: (isSelected) =>
                  getProvider(context, false).changeItemSelection(itemEntry.key, isSelected),
            ))
        .toList();
  }
}