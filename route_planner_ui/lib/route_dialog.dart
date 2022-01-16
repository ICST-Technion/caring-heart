

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:route_planner_ui/logic.dart';
import 'package:item_spec/route_item_service.dart' as DB;
import 'item_list_provider.dart';
import 'selected_item_list.dart';

enum RouteDialogStatus { success, noPickupTime, badDate, badTimes }

class RouteDialogFuncs {

  BuildContext context;
  DateTime selectedDate;

  RouteDialogFuncs({required this.context, required this.selectedDate});

  ItemListProvider getProvider(bool listen) {
    return Provider.of<ItemListProvider>(context, listen: listen);
  }

  void ShowRouteDialog() {
    if (getProvider(false).isSelectedEmpty()) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
              title: Text('לא בחרת מוצרים',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red))));
    } else {
      showDialog(
          context: context,
          builder: (_) => Directionality(
            textDirection: TextDirection.rtl,
            child: Dialog(child: RouteDialogContent()),
          ));
    }
  }

  Widget RouteDialogContent() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        children: [
          SelectedList(context: context).SelectedItemList(false),
          Container(
              margin: EdgeInsets.all(20),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [SizedBox(), SubmitBtn()]))
        ]);
  }

  Widget SubmitBtn() {
    return FloatingActionButton(
        onPressed: () async {
          final status = await SendRoute();
          if (status == RouteDialogStatus.success) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('המסלול הועלה לשרת!')));
          } else if (status == RouteDialogStatus.noPickupTime) {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                    title: Text('יש לבחור שעת איסוף לכל המוצרים',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red))));
          } else if (status == RouteDialogStatus.badDate) {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                    title: Text('התאריך שנבחר אינו חוקי',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red))));
          } else {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                    title: Text('סדר השעות שנבחרו אינו חוקי',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red))));
          }
        },
        child: Icon(Icons.send));
  }

  Future<RouteDialogStatus> SendRoute() async {
    if (getProvider(false).isThereEmptyPickupTime()) {
      return RouteDialogStatus.noPickupTime;
    } else if (Logic.compareDates(selectedDate, DateTime.now()) < 0) {
      return RouteDialogStatus.badDate;
    } else if (!Logic.areTimesLegal(getProvider(true).selectedItems)) {
      return RouteDialogStatus.badTimes;
    }
    await DB.ItemService()
        .addRouteByItemList(getProvider(true).selectedItems, selectedDate);
    return RouteDialogStatus.success;
  }


}