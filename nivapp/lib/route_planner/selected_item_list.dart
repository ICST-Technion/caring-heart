import 'package:flutter/material.dart';
import 'package:nivapp/format_date.dart';
import 'package:nivapp/item_spec.dart';
import 'package:nivapp/logic.dart';
import 'package:nivapp/route_planner/date_utility.dart';
import 'package:nivapp/route_planner/item_info.dart';
import 'package:time_range_picker/time_range_picker.dart';

extension on TimeOfDay {
  TimeOfDay add({int hour = 0, int minute = 0}) {
    return replacing(hour: this.hour + hour, minute: this.minute + minute);
  }
}

class SelectedList {
  BuildContext context;
  List<TextEditingController> timeControllers = [];

  SelectedList({required this.context}) {
    final items = Logic.getRouteProvider(context, true).selectedItems;
    timeControllers = items
        .map((e) => TextEditingController(
            text: e.pickupTime == null
                ? 'בחירת שעות'
                : formatTimeRange(e.pickupTime)))
        .toList();
  }

  // ignore: non_constant_identifier_names
  Widget SelectedItemList(bool draggable) {
    if (!Logic.getRouteProvider(context, false).isSelectedEmpty()) {
      return SizedBox(
        height: Logic.ScreenSize(context).height / 2.4,
        child: ReorderableList(
            shrinkWrap: true,
            itemBuilder: (_context, idx) => getSelectedItem(
                Logic.getRouteProvider(context, true).selectedItems[idx].item,
                idx,
                draggable),
            itemCount:
                Logic.getRouteProvider(context, true).selectedItems.length,
            onReorder: (prev, current) {
              if (current > prev) {
                current = current - 1;
              }
              Logic.getRouteProvider(context, false)
                  .moveSelectedItemAt(prev, current);
            }),
      );
    } else {
      return const Center(
          child: Text(
        'לא נבחרו מוצרים',
        style: TextStyle(fontSize: 15),
      ));
    }
  }

  Widget getSelectedItem(Item item, int idx, bool draggable) {
    return Card(
        key: ValueKey(item.id),
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
        elevation: 3,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SelectedItemInfo(item, idx, draggable),
          ),
        ));
  }

  Widget SelectedItemInfo(Item item, idx, bool draggable) {
    List<Widget> textBoxes = ItemInfoTextBoxes(item, context);
    if (draggable) {
      textBoxes.insert(
          0,
          ReorderableDragStartListener(
              index: idx, child: const Icon(Icons.drag_handle)));
    } else {
      textBoxes.insert(0, SelectTimeRangeBtn(idx));
    }
    return Directionality(
        textDirection: TextDirection.rtl, child: Row(children: textBoxes));
  }

  Widget SelectTimeRangeBtn(int idx) {
    TimeRange? timeRange =
        Logic.getRouteProvider(context, true).selectedItems[idx].pickupTime;

    return Container(
        margin: const EdgeInsets.only(bottom: 8, top: 8),
        width: Logic.ScreenSize(context).width / 13,
        height: Logic.ScreenSize(context).height / 27,
        child: ElevatedButton(
            onPressed: () async {
              TimeRange range = await showDialog(
                  context: context,
                  builder: (context) => TimeRangePickerDialog(timeRange, idx));
              Logic.getRouteProvider(context, false)
                  .changePickupTimeAt(idx, range);
            },
            child: TextField(
                enabled: false,
                textAlign: TextAlign.center,
                textAlignVertical: TextAlignVertical.bottom,
                mouseCursor: SystemMouseCursors.click,
                decoration: const InputDecoration(border: InputBorder.none),
                style: const TextStyle(color: Colors.white),
                controller: timeControllers[idx],
                readOnly: true)));
  }

  TimeRangePickerDialog(TimeRange? timeRange, int idx) {
    TimeOfDay now = TimeOfDay.fromDateTime(DateTime.now());
    if (now.minute % 15 != 0) {
      now = now.add(
          minute: now.minute % 15 < 8 ? -(now.minute % 15) : 15 - now.minute % 15);
    }
    TimeOfDay? start = timeRange == null ? now : timeRange.startTime;
    TimeOfDay? end = timeRange == null ? now.add(hour: 1) : timeRange.endTime;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: MediaQuery.of(context).size.width / 5,
          height: 450,
          child: TimeRangePicker(
            interval: const Duration(minutes: 15),
            snap: true,
            rotateLabels: true,
            fromText: 'משעה',
            toText: 'עד שעה',
            start: start,
            end: end,
            labels: ["0", "3", "6", "9", "12", "15", "18", "21"]
                .asMap()
                .entries
                .map((e) {
              return ClockLabel.fromIndex(idx: e.key, length: 8, text: e.value);
            }).toList(),
            labelOffset: -30,
            hideButtons: true,
            onStartChange: (_start) {
              start = _start;
            },
            onEndChange: (_end) {
              end = _end;
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
              child: Text('ביטול'),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          TextButton(
            child: Text('אישור'),
            onPressed: () {
              final range = TimeRange(startTime: start!, endTime: end!);
              timeControllers[idx].text = formatTimeRange(range);
              Navigator.of(context).pop(range);
            },
          ),
        ],
      ),
    );
  }
}
