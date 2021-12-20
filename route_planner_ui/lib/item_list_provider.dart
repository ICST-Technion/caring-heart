import 'package:flutter/material.dart';
import 'item.dart';
import 'package:tuple/tuple.dart';

class ItemListProvider with ChangeNotifier {
  List<Tuple2<bool, Item>> list;
  List<Item> selectedList;

  ItemListProvider({required this.list, this.selectedList = const []});

  void Sort(sortFunc, bool isAscending) {
    isAscending
        ? list.sort((a, b) => sortFunc(a.item2, b.item2))
        : list.sort((a, b) => sortFunc(b.item2, a.item2));
    notifyListeners();
  }

  void SelectItemAt(int index) {
    list[index] = list[index].withItem1(!list[index].item1);
    notifyListeners();
    if (list[index].item1) {
      selectedList.add(list[index].item2);
    } else {
      selectedList.remove(list[index].item2);
    }
    notifyListeners();
  }
}
