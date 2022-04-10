import 'package:flutter/material.dart';
import 'package:nivapp/driver_interface/driver_interface_provider.dart';
import 'package:nivapp/driver_interface/item_names.dart';
import 'package:nivapp/driver_interface/pickup_card.dart';
import 'package:nivapp/driver_interface/report_dialog.dart';
import 'package:nivapp/driver_interface/report_dialog_provider.dart';
import 'package:nivapp/main.dart';
import 'package:nivapp/pickup_point.dart';
import 'package:nivapp/services/report_service_i.dart';
import 'package:nivapp/services/routes_service_i.dart';
import 'package:provider/provider.dart';

import '../easy_future_builder.dart';
import 'inactive_card.dart';

class DriverInterface extends StatelessWidget {
  const DriverInterface({Key? key}) : super(key: key);
  RoutesServiceI get routesService => injector.get();
  @override
  Widget build(BuildContext context) {
    return easyFutureBuilder<List<PickupPoint>>(
        future: routesService.getItems(),
        doneBuilder: (context, todaysRoute) => ChangeNotifierProvider(
            create: (context) => DriverInterfaceProvider(
                todaysRoute, injector.get<ReportServiceI>()),
            child: const Center(child: PickupPointsCards())));
  }
}

class PickupPointsCards extends StatefulWidget {
  const PickupPointsCards({Key? key}) : super(key: key);

  @override
  State<PickupPointsCards> createState() => _PickupPointsCardsState();
}

class _PickupPointsCardsState extends State<PickupPointsCards> {
  ReportServiceI get reportService => injector.get();

  DriverInterfaceProvider get provider =>
      Provider.of<DriverInterfaceProvider>(context, listen: true);

  @override
  Widget build(BuildContext context) {
    List<Widget> pickupCardsList = provider.uncollectedPickupPoints
        .map((pp) => PickupCard(
            pickupPoint: pp,
            functionality: PickupCardFunctionality.production(
                onAccept: acceptItem, onReject: rejectItem)))
        .toList();

    List<Widget> inactiveList = provider.collectedPickupPoints
        .map((pp) => InactiveCard(
              pickupPoint: pp,
              activateFunc: provider.activateItem,
              status: provider.pickupPointsStatusMap[pp]!,
            ))
        .toList();
    return ListView(children: [...pickupCardsList, ...inactiveList]);
  }

  Future<void> acceptItem(PickupPoint item) async {
    // await DB.ItemService().collectItem(item.item.id);
    bool? rejected = await showDialog(
        context: context,
        builder: (context) => ChangeNotifierProvider(
              create: (context) => ReportDialogProvider(
                  item, ReportDialogType.collect(itemNames), reportService),
              child: const ReportDialog(),
            ));

    if (rejected == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('האיסוף הושלם'),
        duration: Duration(milliseconds: 1200),
      ));
      await provider.acceptItem(item);
    }
    return;
  }

  Future<void> rejectItem(PickupPoint item) async {
    bool? rejected = await showDialog(
        context: context,
        builder: (context) => ChangeNotifierProvider(
              create: (context) => ReportDialogProvider(
                  item, ReportDialogType.cancel(), reportService),
              child: const ReportDialog(),
            ));

    if (rejected == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('האיסוף בוטל'),
        duration: Duration(milliseconds: 1200),
      ));
      await provider.rejectItem(item);
    }
  }
}
