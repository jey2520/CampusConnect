import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String college;
  final String department;
  final String year;
  final String profilePhoto;
  final String bio;
  final DateTime createdAt;
  final DateTime lastLogin;
  final bool verified;
  final String role;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.college,
    required this.department,
    required this.year,
    required this.profilePhoto,
    required this.bio,
    required this.createdAt,
    required this.lastLogin,
    required this.verified,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      college: map['college'] ?? '',
      department: map['department'] ?? '',
      year: map['year'] ?? '',
      profilePhoto: map['profilePhoto'] ?? '',
      bio: map['bio'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (map['lastLogin'] as Timestamp?)?.toDate() ?? DateTime.now(),
      verified: map['verified'] ?? false,
      role: map['role'] ?? 'student',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'college': college,
      'department': department,
      'year': year,
      'profilePhoto': profilePhoto,
      'bio': bio,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': Timestamp.fromDate(lastLogin),
      'verified': verified,
      'role': role,
    };
  }
}
