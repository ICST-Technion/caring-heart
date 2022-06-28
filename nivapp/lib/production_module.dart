import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:nivapp/services/auth_service.dart';
import 'package:nivapp/services/auth_service_i.dart';
import 'package:nivapp/services/init_service.dart';
import 'package:nivapp/services/inventory_service.dart';
import 'package:nivapp/services/inventory_service_i.dart';
import 'package:nivapp/services/report_service.dart';
import 'package:nivapp/services/report_service_i.dart';
import 'package:nivapp/services/routes_service.dart';
import 'package:nivapp/services/routes_service_i.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'driver_interface/extract_phone_numbers.dart';

Injector ProductionModule({bool useTestCollectionAndSheet = false}) {
  final injector = Injector();

  injector.mapWithParams<String>((injector, additionalParameters) {
    if (["inventory", "reports", "routes"]
        .contains(additionalParameters["what"])) {
      final String collectionName = additionalParameters["what"];
      return collectionName + (useTestCollectionAndSheet ? "Test" : "");
    }
    throw Exception("Binding for string not found");
  });

  injector.map<FirebaseAuth>((injector) => FirebaseAuth.instance);
  injector.map<FirebaseFirestore>((injector) => FirebaseFirestore.instance);
  injector
      .map<Future<SharedPreferences>>((i) => SharedPreferences.getInstance());
  injector.map<AuthServiceI>(
      (i) => MyAuth(auth: i.get(), sharedPreferences: i.get()),
      isSingleton: true);
  injector.map<InitService>((i) => InitService(), isSingleton: true);

  injector.map<InventoryServiceI>(
      (i) => InventoryService(
          i.get(), i.get(additionalParameters: {"what": "inventory"})),
      isSingleton: true);
  injector.map<RoutesServiceI>(
      (i) => RoutesService(
          i.get(), i.get(), i.get(additionalParameters: {"what": "routes"})),
      isSingleton: true);
  injector.map<ReportServiceI>(
      (i) => ReportService(i.get(additionalParameters: {"what": "reports"})),
      isSingleton: true);
  injector.map<ExtractPhoneNumbers>((i) => ExtractPhoneNumbers());

  return injector;
}
