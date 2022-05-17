import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:nivapp/driver_interface/positive_inc_dec_counter.dart';
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
  ReportDialogProvider getProvider(BuildContext _context, bool _listen) =>
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
    var collect = getProvider(context, true).type.isCollect();
    if (collect) {
      final autoComplete = TypeAheadField(
          textFieldConfiguration: const TextFieldConfiguration(
              autofocus: true,
              decoration: InputDecoration(
                  labelText: 'חפש פריט', icon: Icon(Icons.add_circle_outline))),
          suggestionsCallback: getProvider(context, false).getItemsSuggestion,
          itemBuilder: (context, String item) => ListTile(
                title: Text(item),
              ),
          onSuggestionSelected:
              getProvider(context, false).onSuggestionSelected);
      widgets.add(autoComplete);
      widgets.addAll(_itemsInputs());
    }
    // final isAcceptingDisabled =
    // collect && getProvider(context, false).isMoreThanZeroItems;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: Text('דיווח איסוף ב' +
            getProvider(context, true).pickupPoint.item.address),
        scrollable: true,
        content: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: widgets,
        ),
        actions: [
          TextButton(
              onPressed: getProvider(context, false).disableAccept
                  ? null
                  : () async {
                      await getProvider(context, false)
                          .reportCurrentSelectedItems();
                      Navigator.of(context).pop(true);
                    },
              child: Text('אשר'))
        ],
      ),
    );
  }

  List<Widget> _itemsInputs() {
    return getProvider(context, false)
        .inventoryItemsCount!
        .entries
        .map((entry) {
      final itemName = entry.key;
      final count = entry.value.value;
      return Row(children: [
        Text(itemName),
        Spacer(),
        PositiveIncDecCounter(
            onPressPlus: () async =>
                getProvider(context, false).addOneToItem(itemName),
            onPressMinus: () async =>
                getProvider(context, false).substractOneFromItem(itemName),
            numberDisplay: count)
      ]);
    }).toList();
  }
}
