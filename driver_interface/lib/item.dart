class Item {
  final String address;
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
  final String pickupTime;
  final String phone;

  Item(
      {required this.address,
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
      required this.pickupTime,
      required this.phone});

  factory Item.fromJson(String id, Map<String, dynamic> json, String time) {
    return Item(
        id: id,
        address: json['address'],
        category: json['category'],
        city: json['city'],
        comments: json['comments'],
        date: json['date'].toDate(),
        description: json['description'],
        email: json['email'],
        isChecked: json['isChecked'],
        isCollected: json['isCollected'],
        name: json['name'],
        pickupTime: time,
        phone: json['phone']);
  }
}