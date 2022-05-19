import 'package:flutter/material.dart';
import 'package:nivapp/format_date.dart';
import 'package:nivapp/item_spec.dart';
import 'package:nivapp/logic.dart';
import 'package:nivapp/route_planner/date_utility.dart';
import 'package:time_range_picker/time_range_picker.dart';

class SelectedList {
  BuildContext context;

  SelectedList({required this.context});

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
    Map info = {
      0: item.name,
      1: item.address,
      2: item.neighborhood,
      3: item.city,
      4: item.phone,
      5: item.description,
      6: item.date,
      7: item.comments,
    };
    List<Widget> textBoxes = [];
    info.forEach((key, value) {
      if (value.runtimeType == DateTime) {
        textBoxes.add(Expanded(
          child: SizedBox(
              width: Logic.ScreenSize(context).width / 12,
              height: Logic.ScreenSize(context).height / 20,
              child: Center(
                child: Text(
                  DateUtil.formatDate(value),
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
              )),
        ));
      } else {
        textBoxes.add(Expanded(
          child: SizedBox(
              width: Logic.ScreenSize(context).width / 12,
              height: Logic.ScreenSize(context).height / 20,
              child: Center(
                child: Tooltip(
                  textStyle: const TextStyle(fontSize: 14),
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 200, 200, 200)),
                  message: value,
                  child: Text(
                    value,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                ),
              )),
        ));
      }
    });
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
        child: ElevatedButton(
            onPressed: () async {
              TimeRange value = await showDialog(
                  context: context,
                  builder: (context) => TimeRangePickerDialog(timeRange));

              Logic.getRouteProvider(context, false)
                  .changePickupTimeAt(idx, value);
            },
            child: timeRange == null
                ? const Text('בחירת שעות')
                : Text(formatTimeRange(Logic.getRouteProvider(context, true)
                    .selectedItems[idx]
                    .pickupTime))));
  }

  TimeRangePickerDialog(TimeRange? timeRange) {
    TimeOfDay? start = timeRange == null
        ? TimeOfDay.fromDateTime(DateTime.now())
        : timeRange.startTime;
    TimeOfDay? end = timeRange == null
        ? TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1)))
        : timeRange.endTime;
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
              Navigator.of(context)
                  .pop(TimeRange(startTime: start!, endTime: end!));
            },
          ),
        ],
      ),
    );
  }
}
