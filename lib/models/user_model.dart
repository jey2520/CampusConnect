import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String profilePhoto;
  final String phoneNumber;
  final String college;
  final String department;
  final String year;
  final String bio;
  final DateTime createdAt;
  final DateTime lastLogin;
  final String authenticationProvider;
  final String role;
  final String status;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.profilePhoto,
    required this.phoneNumber,
    required this.college,
    required this.department,
    required this.year,
    required this.bio,
    required this.createdAt,
    required this.lastLogin,
    this.authenticationProvider = 'Google',
    this.role = 'Student',
    this.status = 'Active',
  });

  String get initials {
    if (fullName.isEmpty) return 'CC';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts.first[0] + parts.last[0]).toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? map['name'] ?? '',
      email: map['email'] ?? '',
      profilePhoto: map['profilePhoto'] ?? '',
      phoneNumber: map['phoneNumber'] ?? map['phone'] ?? '',
      college: map['college'] ?? '',
      department: map['department'] ?? '',
      year: map['year'] ?? '',
      bio: map['bio'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (map['lastLogin'] as Timestamp?)?.toDate() ?? DateTime.now(),
      authenticationProvider: map['authenticationProvider'] ?? 'Google',
      role: map['role'] ?? 'Student',
      status: map['status'] ?? 'Active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'profilePhoto': profilePhoto,
      'phoneNumber': phoneNumber,
      'college': college,
      'department': department,
      'year': year,
      'bio': bio,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': Timestamp.fromDate(lastLogin),
      'authenticationProvider': authenticationProvider,
      'role': role,
      'status': status,
    };
  }
}
