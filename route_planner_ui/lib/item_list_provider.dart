import 'package:flutter/material.dart';
import 'package:item_spec/item_spec.dart';
import 'package:tuple/tuple.dart';

class ItemListProvider with ChangeNotifier {
  List<Tuple2<bool, Item>> list;

  ItemListProvider({required this.list});

  void Sort(sortFunc, bool isAscending) {
    isAscending
        ? list.sort((a, b) => sortFunc(a.item2, b.item2))
        : list.sort((a, b) => sortFunc(b.item2, a.item2));
    notifyListeners();
  }

  void SelectItemAt(int index) {
    list[index] = list[index].withItem1(!list[index].item1);
    notifyListeners();
  }

  bool isSelectedEmpty() {
    return list.any((element) => element.item1);
  }
}
