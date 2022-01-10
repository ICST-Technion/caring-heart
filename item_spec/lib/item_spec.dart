library item_spec;

extension _GetValue<U, V> on Map<U, V> {
  V getNotNull(U key) {
    return this[key] ?? (throw Exception("$key is not in map $this"));
  }
}

Map<String, dynamic> _tempBridgeToNewFirebase(
    Map<String, dynamic> oldFirebaseItem) {
  final Map<String, dynamic> res = Map.from(oldFirebaseItem);

  // arbitrary values that are a function of the old item
  final floor = (res['name'] as String).length % 5;
  res['floor'] = '$floor';
  res['apartment'] = '${floor + 1}';
  return res;
}

class Item {
  final String address;
  final String floor;
  final String apartment;
  final String neighborhood;
  final String category;
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
      required this.category,
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
    json = _tempBridgeToNewFirebase(json);
    return Item(
        id: id,
        address: json.getNotNull('address'),
        floor: json.getNotNull('floor'),
        apartment: json.getNotNull('apartment'),
        neighborhood: json.getNotNull('neighborhood'),
        category: json.getNotNull('category'),
        city: json.getNotNull('city'),
        comments: json.getNotNull('comments'),
        date: json.getNotNull('date').toDate(),
        description: json.getNotNull('description'),
        email: json.getNotNull('email'),
        isChecked: json.getNotNull('isChecked'),
        isCollected: json.getNotNull('isCollected'),
        name: json.getNotNull('name'),
        // pickupTime: time,
        phone: json.getNotNull('phone').toString());
  }
}
