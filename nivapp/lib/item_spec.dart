// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

extension _GetValue<U, V> on Map<U, V> {
  V getNotNull(U key) {
    return this[key] ?? (throw Exception("$key is not in map $this"));
  }
}

class Item {
  final String address;
  final String floor;
  final String apartment;
  final String neighborhood;
  final String city;
  final String comments;
  final DateTime date;
  final String description;
  final String email;
  final bool isChecked;
  final bool isCollected;
  final String name;
  final String id;

  // final String pickupTime;
  final String phone;
  Item({
    required this.address,
    required this.floor,
    required this.apartment,
    required this.neighborhood,
    required this.city,
    required this.comments,
    required this.date,
    required this.description,
    required this.email,
    required this.isChecked,
    required this.isCollected,
    required this.name,
    required this.id,
    required this.phone,
  });

  // Item(
  //     {required this.address,
  //     required this.floor,
  //     required this.apartment,
  //     required this.neighborhood,
  //     // required this.category,
  //     required this.city,
  //     required this.comments,
  //     required this.date,
  //     required this.description,
  //     required this.email,
  //     required this.isChecked,
  //     required this.isCollected,
  //     required this.name,
  //     required this.id,
  //     // required this.pickupTime,
  //     required this.phone});

  factory Item.fromJson(String id, Map<String, dynamic> json) {
    // json = _tempBridgeToNewFirebase(json);
    return Item(
        id: id,
        address: json.getNotNull('address').toString(),
        floor: json.getNotNull('floor').toString(),
        apartment: json.getNotNull('apartment').toString(),
        neighborhood: json.getNotNull('neighborhood').toString(),
        city: json.getNotNull('city').toString(),
        comments: json.getNotNull('comments').toString(),
        date: getDateTimeType(json.getNotNull('date')),
        description: json.getNotNull('description').toString(),
        email: json.getNotNull('email').toString(),
        isChecked: json.getNotNull('isChecked'),
        isCollected: json.getNotNull('isCollected'),
        name: json.getNotNull('name').toString(),
        // pickupTime: time,
        phone: json.getNotNull('phone').toString());
  }

  String get fullAddress => '${this.address}, ${this.city}';

  // @override
  // bool operator ==(Object other) {
  //   if (other is! Item) {
  //     return false;
  //   }
  //   return address == other.address &&
  //       floor == other.address &&
  //       apartment == other.apartment &&
  //       neighborhood == other.neighborhood &&
  //       city == other.city &&
  //       comments == other.comments &&
  //       date == other.date &&
  //       description == other.description &&
  //       email == other.email &&
  //       isChecked == other.isChecked &&
  //       isCollected == other.isCollected &&
  //       name == other.name &&
  //       id == other.id &&
  //       //
  //       phone == other.phone;
  // }

  // @override
  // int get hashCode => hash(id, phone);

  Item copyWith({
    String? address,
    String? floor,
    String? apartment,
    String? neighborhood,
    String? city,
    String? comments,
    DateTime? date,
    String? description,
    String? email,
    bool? isChecked,
    bool? isCollected,
    String? name,
    String? id,
    String? phone,
  }) {
    return Item(
      address: address ?? this.address,
      floor: floor ?? this.floor,
      apartment: apartment ?? this.apartment,
      neighborhood: neighborhood ?? this.neighborhood,
      city: city ?? this.city,
      comments: comments ?? this.comments,
      date: date ?? this.date,
      description: description ?? this.description,
      email: email ?? this.email,
      isChecked: isChecked ?? this.isChecked,
      isCollected: isCollected ?? this.isCollected,
      name: name ?? this.name,
      id: id ?? this.id,
      phone: phone ?? this.phone,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'address': address,
      'floor': floor,
      'apartment': apartment,
      'neighborhood': neighborhood,
      'city': city,
      'comments': comments,
      'date': date.millisecondsSinceEpoch,
      'description': description,
      'email': email,
      'isChecked': isChecked,
      'isCollected': isCollected,
      'name': name,
      'id': id,
      'phone': phone,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      address: map['address'] as String,
      floor: map['floor'] as String,
      apartment: map['apartment'] as String,
      neighborhood: map['neighborhood'] as String,
      city: map['city'] as String,
      comments: map['comments'] as String,
      date: getDateTimeType(map.getNotNull('date')),
      description: map['description'] as String,
      email: map['email'] as String,
      isChecked: map['isChecked'] as bool,
      isCollected: map['isCollected'] as bool,
      name: map['name'] as String,
      id: map['id'] as String,
      phone: map['phone'] as String,
    );
  }

  factory Item.emptyItem() {
    return Item(address: "", floor: "", apartment: "", neighborhood: "", city: "", comments: "", date: DateTime.now(), description: "", email: "", isChecked: false, isCollected: false, name: "", id: "", phone: "");
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'Item(address: $address, floor: $floor, apartment: $apartment, neighborhood: $neighborhood, city: $city, comments: $comments, date: $date, description: $description, email: $email, isChecked: $isChecked, isCollected: $isCollected, name: $name, id: $id, phone: $phone)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Item &&
        other.address == address &&
        other.floor == floor &&
        other.apartment == apartment &&
        other.neighborhood == neighborhood &&
        other.city == city &&
        other.comments == comments &&
        other.date == date &&
        other.description == description &&
        other.email == email &&
        other.isChecked == isChecked &&
        other.isCollected == isCollected &&
        other.name == name &&
        other.id == id &&
        other.phone == phone;
  }

  @override
  int get hashCode {
    return address.hashCode ^
        floor.hashCode ^
        apartment.hashCode ^
        neighborhood.hashCode ^
        city.hashCode ^
        comments.hashCode ^
        date.hashCode ^
        description.hashCode ^
        email.hashCode ^
        isChecked.hashCode ^
        isCollected.hashCode ^
        name.hashCode ^
        id.hashCode ^
        phone.hashCode;
  }

}

DateTime getDateTimeType(dynamic dateTimeOrTimestep) {
  if (dateTimeOrTimestep is DateTime) {
    return dateTimeOrTimestep;
  }
  return (dateTimeOrTimestep as Timestamp).toDate();
}
