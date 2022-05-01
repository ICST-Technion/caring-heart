import 'package:flutter/material.dart';
import 'package:nivapp/item_spec.dart';
import 'package:nivapp/pickup_point.dart';
import 'package:nivapp/services/routes_service_i.dart';
import 'package:tuple/tuple.dart';

import 'date_utility.dart';

class RoutePlannerProvider with ChangeNotifier {
  late List<Tuple2<bool, Item>> itemList;
  List<PickupPoint> selectedItems = [];
  bool isLoading = false;
  final RoutesServiceI _routeService;

  bool _isAscending = true;
  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;

  TextEditingController _dateBtnTextCtrl = TextEditingController();

  TextEditingController get dateBtnTextCtrl => _dateBtnTextCtrl;

  RoutePlannerProvider(this._routeService,
      {required List<Item> itemList, required List<PickupPoint> route}) {
    this.itemList = itemList.map((e) => Tuple2(false, e)).toList();
    _dateBtnTextCtrl.text = DateUtil.formatDate(DateTime.now());
    selectedItems = route;
    this.itemList = getItemTupleListFromSelectedItems();
  }

  void Sort(int Function(Item, Item) sortFunc) {
    _isAscending = !_isAscending;
    _isAscending
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
      selectedItems.removeWhere((e) => e.item.id == itemList[index].item2.id);
    }
    notifyListeners();
  }

  bool isSelectedEmpty() {
    return selectedItems.isEmpty;
  }

  bool isThereEmptyPickupTime() {
    return selectedItems.any((element) => element.pickupTime == '');
  }

  Future<void> loadNewRoute(DateTime? date, {bool notify = true}) async {
    if (date == null) {
      return;
    }
    _selectedDate = date;
    _dateBtnTextCtrl.text = DateUtil.formatDate(selectedDate);
    isLoading = true;
    if (notify) {
      notifyListeners();
    }
    selectedItems = await _routeService.getItems(getDay: () => date);
    itemList = getItemTupleListFromSelectedItems();
    isLoading = false;
    if (notify) {
      notifyListeners();
    }
  }

  getItemTupleListFromSelectedItems() {
    List<String> tempItemList = selectedItems.map((e) => e.item.id).toList();
    return itemList
        .map((e) => (tempItemList.contains(e.item2.id))
            ? Tuple2(true, e.item2)
            : Tuple2(false, e.item2))
        .toList();
  }

  void changePickupTimeAt(idx, time) {
    selectedItems[idx] =
        PickupPoint(item: selectedItems[idx].item, pickupTime: time!);
  }

  List<PickupPoint> getSelectedItems() {
    return selectedItems;
  }

  void moveSelectedItemAt(prev, next) {
    final item = selectedItems.removeAt(prev);
    selectedItems.insert(next, item);
    notifyListeners();
  }

  Future<void> addCurrentRouteToDate(DateTime date) async {
    await _routeService.addRouteByItemList(selectedItems, date);
  }
}
