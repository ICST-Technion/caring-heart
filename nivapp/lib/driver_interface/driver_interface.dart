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
        future: routesService.getItems(getDay: () => DateTime(2021,12,22)),
        doneBuilder: (context, todaysRoute) => ChangeNotifierProvider(
            create: (context) => DriverInterfaceProvider(
                todaysRoute, injector.get<ReportServiceI>()),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                appBar: AppBar(title: Text("איסוף תרומות")),
                body: Center(child: PickupPointsCards()),
              ),
            )));
  }
}

class PickupPointsCards extends StatefulWidget {
  const PickupPointsCards({Key? key}) : super(key: key);

  @override
  State<PickupPointsCards> createState() => _PickupPointsCardsState();
}

class _PickupPointsCardsState extends State<PickupPointsCards> {
  ReportServiceI get reportService => injector.get();

  DriverInterfaceProvider getProvider(BuildContext _context, bool _listen) =>
      Provider.of<DriverInterfaceProvider>(_context, listen: _listen);

  @override
  Widget build(BuildContext context) {
    List<Widget> pickupCardsList = getProvider(context, true).uncollectedPickupPoints
        .map((pp) => PickupCard(
            pickupPoint: pp,
            functionality: PickupCardFunctionality.production(
                onAccept: acceptItem, onReject: rejectItem)))
        .toList();

    List<Widget> inactiveList = getProvider(context, true).collectedPickupPoints
        .map((pp) => InactiveCard(
              pickupPoint: pp,
              activateFunc: getProvider(context, false).activateItem,
              status: getProvider(context, true).pickupPointsStatusMap[pp]!,
            ))
        .toList();
    return ListView(children: [...pickupCardsList, ...inactiveList]);
  }

  Future<void> acceptItem(PickupPoint item) async {
    // await DB.ItemService().collectItem(item.item.id);
    bool? accepted = await showDialog(
        context: context,
        builder: (context) => ChangeNotifierProvider(
              create: (context) => ReportDialogProvider(
                  item, ReportDialogType.collect(itemNames), reportService),
              child: const ReportDialog(),
            ));

    if (accepted == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('האיסוף הושלם'),
        duration: Duration(milliseconds: 1200),
      ));
      await getProvider(context, false).acceptItem(item);
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
      await getProvider(context, false).rejectItem(item);
    }
  }
}
