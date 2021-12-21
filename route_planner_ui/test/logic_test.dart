// import 'package:flutter/material.dart';
// import 'package:test/test.dart';
import 'package:flutter/foundation.dart';
import 'package:route_planner_ui/item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:route_planner_ui/engine.dart';


void main() async {

  // test("Should return an empty list", () {
  //   List<MyPoint> result = Logic.routePlanningEngine(List<MyPoint>.empty(), 2);
  //   assert(result.isEmpty);
  // });

   test("should do something", () async {
    List<String> s = ["pinsker 51, haifa", "pinsker 53, haifa", "pinsker 49, haifa", "pinsker 29, haifa", "hague 58, haifa"];
    List<Item> items = List<Item>.generate(5, (i) => Item(
        address: s[i],
        category: "",
        city: "",
        comments: "",
        date: DateTime(2005),
        description: "",
        email: "",
        isChecked: true,
        isCollected: true,
        name: "",
        id: "",
        phone: ""
    ));
    // var item = Item(
    //     address: "",
    //     category: "",
    //     city: "",
    //     comments: "",
    //     date: DateTime(2005),
    //     description: "",
    //     email: "",
    //     isChecked: true,
    //     isCollected: true,
    //     name: "",
    //     id: "",
    //     phone: ""
    // );
    var rpe = (await Engine.routePlanningEngine(items, 5));
    int l = rpe.length;
    for (final i in rpe){
      debugPrint(i.address);
    }
    assert(l ==  4);
  });


}