import 'package:flutter/material.dart';
import 'package:driver_interface/pickup_card.dart';
import 'package:driver_interface/report_service.dart';
import 'package:expandable/expandable.dart';
import 'package:item_spec/item_spec.dart';
import 'package:item_spec/pickup_point.dart';
import 'package:url_launcher/url_launcher.dart';

class InactiveCard extends StatefulWidget {
  const InactiveCard({ Key? key, required this.pickupPoint, required this.activateFunc, required this.status} ) : super(key: key);
  final PickupReportStatus status;
  final PickupPoint pickupPoint;
  final Future<void> Function(PickupPoint) activateFunc;

  @override
  _InactiveCardState createState() => _InactiveCardState();
}

class _InactiveCardState extends State<InactiveCard>{
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child:  ListItem(widget.pickupPoint), 
      // elevation: 0,
      color: (widget.status == PickupReportStatus.collected) ? Colors.lightGreen[50] : Colors.red[50] 
      );
  }

  Widget ListItem(PickupPoint item) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: ItemStuff(item), 
      ),
    );
  }

  Row ItemStuff(PickupPoint item) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      pickupInfo(item),
      // Text(description, style: const TextStyle(fontSize: 18)),
      TextButton(
        child: Text("החזר מוצר לרשימה"),
        onPressed: () => widget.activateFunc(item)

        )
    ]);
  }

  Widget pickupInfo(PickupPoint item) {
    final address = item.item.address;
    final time = item.pickupTime;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(address, style: const TextStyle(fontSize: 20)),
            Text(time, style: const TextStyle(fontSize: 16))
          ],
        )
      ],
    );
  }
}




