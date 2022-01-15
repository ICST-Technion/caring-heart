import 'package:flutter/material.dart';
import 'package:item_spec/item_spec.dart';
import 'package:item_spec/pickup_point.dart';
import 'package:tuple/tuple.dart';

class ItemListProvider with ChangeNotifier {
  List<Tuple2<bool, Item>> itemList;
  List<PickupPoint> selectedItems;

  ItemListProvider({required this.itemList, required this.selectedItems});

  void Sort(sortFunc, bool isAscending) {
    isAscending
        ? itemList.sort((a, b) => sortFunc(a.item2, b.item2))
        : itemList.sort((a, b) => sortFunc(b.item2, a.item2));
    notifyListeners();
  }

  void SelectItemAt(int index) {
    itemList[index] = itemList[index].withItem1(!itemList[index].item1);
    if (itemList[index].item1) {
      selectedItems
          .add(PickupPoint(item: itemList[index].item2, pickupTime: ""));
    } else {
      selectedItems.removeWhere((e) => e.item == itemList[index].item2);
    }
    notifyListeners();
  }

  bool isSelectedEmpty() {
    return selectedItems.isEmpty;
  }

  void changePickupTimeAt(idx, time) {
    selectedItems[idx] =
        PickupPoint(item: selectedItems[idx].item, pickupTime: time!);
  }

  List<PickupPoint> getSelectedItems() {
    return selectedItems;
  }

  moveSelectedItemAt(prev, next) {
    final item = selectedItems.removeAt(prev);
    selectedItems.insert(next, item);
    notifyListeners();
  }
}
