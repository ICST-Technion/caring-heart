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

  Item(
      {required this.address,
      required this.floor,
      required this.apartment,
      required this.neighborhood,
      // required this.category,
      required this.city,
      required this.comments,
      required this.date,
      required this.description,
      required this.email,
      required this.isChecked,
      required this.isCollected,
      required this.name,
      required this.id,
      // required this.pickupTime,
      required this.phone});

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
        date: json.getNotNull('date').toDate(),
        description: json.getNotNull('description').toString(),
        email: json.getNotNull('email').toString(),
        isChecked: json.getNotNull('isChecked'),
        isCollected: json.getNotNull('isCollected'),
        name: json.getNotNull('name').toString(),
        // pickupTime: time,
        phone: json.getNotNull('phone').toString());
  }
}
