import 'package:flutter/material.dart';
import 'package:nivapp/logic.dart';
import 'package:provider/provider.dart';
import 'selected_item_list.dart';

enum RouteDialogStatus { success, noPickupTime, badDate, badTimes }

class RouteDialog {
  BuildContext context;
  DateTime selectedDate;

  RouteDialog({required this.context, required this.selectedDate});

  // ignore: non_constant_identifier_names
  void ShowRouteDialog() {
    if (Logic.getRouteProvider(context, false).isSelectedEmpty()) {
      showDialog(
          context: context,
          builder: (context) => const AlertDialog(
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

  // ignore: non_constant_identifier_names
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

  // ignore: non_constant_identifier_names
  Widget SubmitBtn() {
    return FloatingActionButton.extended(
        onPressed: () async {
          final status = await SendRoute();
          if (status == RouteDialogStatus.success) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('המידע התעדכן בהצלחה!')));
          } else if (status == RouteDialogStatus.noPickupTime) {
            showDialog(
                context: context,
                builder: (context) => const AlertDialog(
                    title: Text('יש לבחור שעת איסוף לכל המוצרים',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red))));
          } else if (status == RouteDialogStatus.badDate) {
            showDialog(
                context: context,
                builder: (context) => const AlertDialog(
                    title: Text('התאריך שנבחר אינו חוקי',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red))));
          } /*else {
            showDialog(
                context: context,
                builder: (context) => const AlertDialog(
                    title: Text('סדר השעות שנבחרו אינו חוקי',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red))));
          }*/
        },
        label: Text('שליחה'),
        icon: const Icon(Icons.send));
  }

  // ignore: non_constant_identifier_names
  Future<RouteDialogStatus> SendRoute() async {
    if (Logic.getRouteProvider(context, false).isThereEmptyPickupTime()) {
      return RouteDialogStatus.noPickupTime;
    }
    /*else if (Logic.compareDates(selectedDate, DateTime.now()) < 0) {
      return RouteDialogStatus.badDate;
    } */
    /*else if (!Logic.areTimesLegal(
        Logic.getRouteProvider(context, false).selectedItems)) {
      return RouteDialogStatus.badTimes;
    }*/
    await Logic.getRouteProvider(context, false)
        .addCurrentRouteToDate(selectedDate);
    return RouteDialogStatus.success;
  }
}
