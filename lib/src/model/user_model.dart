class UserModel {
  int id;
  String name;
  String email;
  String phone;
  String address;
  int role; // Make roleStatus nullable

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.role, // Make roleStatus optional
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // Convert json data to object
      id: json['id'],
      name: json['f_name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      role: json['role'],
    );
  }
}
