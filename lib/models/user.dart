class User {
  final String id;
  String name, email, phone, province, area, address;
  int points;
  bool isAdmin;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.province,
    required this.area,
    required this.address,
    this.points = 0,
    this.isAdmin = false,
  });
}
