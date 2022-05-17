import 'package:flutter/material.dart';

class PositiveIncDecCounter extends StatelessWidget {
  final Future<void> Function() onPressPlus;
  final Future<void> Function() onPressMinus;
  final int numberDisplay;
  const PositiveIncDecCounter(
      {Key? key,
      required this.onPressPlus,
      required this.onPressMinus,
      required this.numberDisplay})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onPressPlus,
          icon: const Icon(Icons.add),
          splashRadius: 24,
        ),
        Text("$numberDisplay"),
        IconButton(
            onPressed: onPressMinus,
            icon: const Icon(Icons.remove),
            splashRadius: 24)
      ],
    );
  }
}
