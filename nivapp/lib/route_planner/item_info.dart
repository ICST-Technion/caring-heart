import 'package:flutter/material.dart';
import 'package:nivapp/driver_interface/extract_phone_numbers.dart';
import 'package:nivapp/item_spec.dart';
import 'package:nivapp/logic.dart';
import 'package:nivapp/route_planner/date_utility.dart';

List<Widget> ItemInfoTextBoxes(Item item, BuildContext context) {
  List<PhoneNumberExtraction> phones = ExtractPhoneNumbers().call(item.phone);
  Map info = {
    0: item.name,
    1: item.address,
    2: item.neighborhood,
    3: item.city,
    4: phones[0].phoneNumber,
    5: phones.length > 1 ? phones[1].phoneNumber : '-',
    6: item.description,
    7: item.date,
    8: item.comments,
  };
  List<Widget> textBoxes = [];
  info.forEach((key, value) {
    if (value.runtimeType == DateTime) {
      textBoxes.add(Expanded(
        child: SizedBox(
            width: Logic.ScreenSize(context).width / 12,
            height: Logic.ScreenSize(context).height / 20,
            child: Center(
              child: Text(
                DateUtil.formatDate(value),
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
            )),
      ));
    } else {
      textBoxes.add(Expanded(
        child: SizedBox(
            width: Logic.ScreenSize(context).width / 12,
            height: Logic.ScreenSize(context).height / 20,
            child: Center(
              child: Tooltip(
                textStyle: const TextStyle(fontSize: 14),
                decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 200, 200, 200)),
                message: value,
                child: Text(
                  value,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
              ),
            )),
      ));
    }
  });
  return textBoxes;
}
