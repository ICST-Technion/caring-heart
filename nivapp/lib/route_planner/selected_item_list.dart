import 'package:flutter/material.dart';
import 'package:nivapp/item_spec.dart';
import 'package:nivapp/logic.dart';
import 'package:nivapp/route_planner/date_utility.dart';

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
            itemCount: Logic.getRouteProvider(context, true).selectedItems.length,
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
      textBoxes.insert(0, SelectTimeBtn(idx));
    }
    return Directionality(
        textDirection: TextDirection.rtl, child: Row(children: textBoxes));
  }

  Widget SelectTimeBtn(int idx) {
    List<String> options = [];
    String time =
        Logic.getRouteProvider(context, true).selectedItems[idx].pickupTime;
    for (int h = 8; h <= 18; h++) {
      for (int m = 0; m < 60; m += 15) {
        String minutes = m == 0 ? '00' : m.toString();
        String hours = (h / 10 == 0) ? '0' + h.toString() : h.toString();
        options.add('$hours:$minutes');
      }
    }
    return Container(
      height: Logic.ScreenSize(context).height / 21,
      width: Logic.ScreenSize(context).width / 15,
      margin: const EdgeInsets.only(bottom: 8),
      child: DropdownButtonFormField(
        alignment: Alignment.center,
        value: time.isEmpty
            ? null
            : Logic.getRouteProvider(context, true).selectedItems[idx].pickupTime,
        items: options.map((String time) {
          return DropdownMenuItem<String>(
            value: time,
            child: Text(time),
          );
        }).toList(),
        hint: const Text('בחירת שעה', style: TextStyle(color: Colors.pinkAccent)),
        onChanged: (String? value) {
          Logic.getRouteProvider(context, false).changePickupTimeAt(idx, value!);
        },
      ),
    );
  }
}
