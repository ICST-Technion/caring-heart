import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main(List<String> args) async {
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyAthHM9OIfBl2ZGEQXpLNNReIlscA0DDzY",
        authDomain: "caring-heart-aa1c1.firebaseapp.com",
        projectId: "caring-heart-aa1c1",
        storageBucket: "caring-heart-aa1c1.appspot.com",
        messagingSenderId: "182054728263",
        appId: "1:182054728263:web:148c0f7de618b0bfc07762",
        measurementId: "G-L7KXZNNTP3"),
  );
  final inventory = await FirebaseFirestore.instance.collection('inventoryTest');
  final items = await inventory.get();
  var i = 0;
  for (final doc in items.docs) {
    final id = doc.id;
    var data = doc.data();
    print("Before");
    print(data);
    final description = (data['category'] as String) + ' - ' + (data['description'] as String);
    data.remove('category');
    data.remove('description');
    data['description'] = description;
    data["floor"] = "0";
    data["apartment"] = "1";
    print("After");
    print(data);
    // await inventory.doc(id).set(data);
    i++;
  }
}