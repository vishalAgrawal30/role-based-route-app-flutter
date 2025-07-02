// ignore_for_file: file_names

class UserModel {
  final int? id;
  final String userName;
  final String email;
  final String password;
  final String address;
  final String? city;
  final String? gender;
  final DateTime? dob;
  final String? profileImagePath;
  final String role; // ✅ New role field (admin or employee)

  UserModel({
    this.id,
    required this.userName,
    required this.email,
    required this.password,
    required this.address,
    this.city,
    this.gender,
    this.dob,
    this.profileImagePath,
    required this.role,
  });

  // ✅ From SQLite
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['userId'],
      userName: map['userName'],
      email: map['email'],
      password: map['password'],
      address: map['address'],
      city: map['city'],
      gender: map['gender'],
      dob: map['dob'] != null ? DateTime.tryParse(map['dob']) : null,
      profileImagePath: map['profileImagePath'],
      role: map['role'],
    );
  }

  // ✅ To SQLite
  Map<String, dynamic> toMap() {
    return {
      'userId': id,
      'userName': userName,
      'email': email,
      'password': password,
      'address': address,
      'city': city,
      'gender': gender,
      'dob': dob?.toIso8601String(),
      'profileImagePath': profileImagePath,
      'role': role,
    };
  }

  // ✅ From API JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      userName: json['userName'],
      email: json['email'],
      password: json['password'],
      address: json['address'],
      city: json['city'],
      gender: json['gender'],
      dob: json['dob'] != null ? DateTime.tryParse(json['dob']) : null,
      profileImagePath: json['profileImagePath'],
      role: json['role'],
    );
  }

  // ✅ To API JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'email': email,
      'password': password,
      'address': address,
      'city': city,
      'gender': gender,
      'dob': dob?.toIso8601String(),
      'profileImagePath': profileImagePath,
      'role': role,
    };
  }
}
