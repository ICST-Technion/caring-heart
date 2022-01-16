import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:item_spec/item_spec.dart';
import 'package:item_spec/pickup_point.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> _callOnPress(PickupPoint pickupPoint) async {
  launch('tel:${pickupPoint.item.phone}');
}

Future<void> _openWazeOnPress(PickupPoint pickupPoint) async {
  launch('https://waze.com/ul?q=${pickupPoint.item.address}');
}

class PickupCardFunctionality {
  final Future<void> Function(PickupPoint pickupPoint) onAccept;
  final Future<void> Function(PickupPoint pickupPoint) onReject;
  final Future<void> Function(PickupPoint pickupPoint) onCallButton;
  final Future<void> Function(PickupPoint pickupPoint) onNavigateButton;

  PickupCardFunctionality.custom(
      {required this.onAccept,
      required this.onReject,
      this.onCallButton = _callOnPress,
      this.onNavigateButton = _openWazeOnPress});

  factory PickupCardFunctionality.production(
      {required Future<void> Function(PickupPoint pickupPoint) onAccept,
      required Future<void> Function(PickupPoint pickupPoint) onReject}) {
    return PickupCardFunctionality.custom(
        onAccept: onAccept, onReject: onReject);
  }

  factory PickupCardFunctionality.log({logger = print}) {
    return PickupCardFunctionality.custom(
      onAccept: (e) async {
        logger('accept ${e.item}');
      },
      onReject: (e) async {
        logger('reject ${e.item}');
      },
      onCallButton: (e) async {
        logger('call ${e.item}');
      },
      onNavigateButton: (e) async {
        logger('navigate ${e.item}');
      },
    );
  }
}

class PickupCard extends StatefulWidget {
  final PickupPoint pickupPoint;
  final PickupCardFunctionality functionality;
  PickupCard({
    Key? key,
    required this.pickupPoint,
    required this.functionality,
  }) : super(key: key);

  @override
  _PickupCardState createState() => _PickupCardState();
}

class _PickupCardState extends State<PickupCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      elevation: 4,
      child: ExpandablePanel(
        header: ListItem(widget.pickupPoint),
        collapsed: Container(),
        expanded: CardButtons(widget.pickupPoint),
        theme: const ExpandableThemeData(
            headerAlignment: ExpandablePanelHeaderAlignment.center),
      ),
    );
  }

  Widget CardButtons(PickupPoint item) {
    return Center(
      child: Column(
        children: [const Divider(height: 1), AcceptOrReject(item)],
      ),
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
    final description = item.item.description;
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      pickupInfo(item),
      Text(description, style: const TextStyle(fontSize: 18)),
      itemButtons(item)
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

  Widget itemButtons(PickupPoint pickupPoint) {
    final phone = pickupPoint.item.phone;
    final address = pickupPoint.item.address;
    return Column(
      children: [
        IconButton(
            splashRadius: 24,
            onPressed: () => widget.functionality.onCallButton(pickupPoint),
            icon: const Icon(Icons.phone, color: Colors.green)),
        IconButton(
            splashRadius: 24,
            onPressed: () => widget.functionality.onNavigateButton(pickupPoint),
            icon: const Icon(Icons.map, color: Colors.blue))
      ],
    );
  }

  Widget AcceptOrReject(PickupPoint item) {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: TextButton(
                onPressed: () => widget.functionality.onAccept(item),
                child: const Text(
                  'אישור',
                  style: TextStyle(color: Colors.green, fontSize: 18),
                ),
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.symmetric(vertical: 15)),
                  overlayColor: MaterialStateProperty.all<Color>(
                      Colors.green.withAlpha(20)),
                )),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: TextButton(
                onPressed: () => widget.functionality.onReject(item),
                child: const Text('ביטול',
                    style: TextStyle(color: Colors.red, fontSize: 18)),
                style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.symmetric(vertical: 15)))),
          ),
        ],
      ),
    );
  }
}
