// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:nivapp/item_spec.dart';
import 'package:nivapp/route_planner/route_planner_provider.dart';
import 'package:provider/provider.dart';

import 'pickup_point.dart';

class Logic {
  static final List<String> _emails = [
    "caringhearttech@gmail.com",
    "levchash@levchash.co.il"
  ];

  static RoutePlannerProvider getRouteProvider(
          BuildContext _context, bool _listen) =>
      Provider.of<RoutePlannerProvider>(_context, listen: _listen);

  static bool isEmailValid(String? email) {
    return _emails.contains(email);
  }

  static Size ScreenSize(context) {
    return MediaQuery.of(context).size;
  }

  static int sortByNeighbors(Item a, Item b) {
    return a.neighborhood.compareTo(b.neighborhood);
  }

  static int sortByDesc(Item a, Item b) {
    return a.description.compareTo(b.description);
  }

  static int sortByCity(Item a, Item b) {
    return a.city.compareTo(b.city);
  }

  static int sortByDate(Item a, Item b) {
    return a.date.compareTo(b.date);
  }

  static bool areTimesLegal(List<PickupPoint> list) {
    for (int i = 0; i < list.length - 1; i++) {
      String t1 = list[i].pickupTime, t2 = list[i + 1].pickupTime;
      final h1 = int.parse(t1.split(':')[0]), m1 = int.parse(t1.split(':')[1]);
      final h2 = int.parse(t2.split(':')[0]), m2 = int.parse(t2.split(':')[1]);
      if (h1 > h2 || (h1 == h2 && m1 > m2)) {
        return false;
      }
    }
    return true;
  }
}
