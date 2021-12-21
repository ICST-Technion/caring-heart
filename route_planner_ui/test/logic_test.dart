// import 'package:flutter/material.dart';
// import 'package:test/test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:route_planner_ui/engine.dart';
import 'package:route_planner_ui/item.dart';

void main(){

  List<Item> items = List<Item>.empty();
  test("Empty List, k is zero", () async {
    List<Item> res = await Engine.routePlanningEngine(items, 0);
    assert(res.isEmpty);
  });

  test("Empty List, k is not zero", () async {
    List<Item> res = await Engine.routePlanningEngine(items, 3);
    assert(res.isEmpty);
  });

  // items.add(Item(
  //     address: "address",
  //     category: "Couch",
  //     city: "Haifa",
  //     comments: "",
  //     date: DateTime.now(),
  //     description:"",
  //     email: "mail@gmail.com",
  //     isChecked: true,
  //     isCollected: false,
  //     name: "Yosef",
  //     id: "",
  //     phone: "123"
  // ));

  // test("One element, k is 1", () async {
  //   List<Item> res = await Engine.routePlanningEngine(items, 1);
  //   assert(res.length == 1);
  // });

}