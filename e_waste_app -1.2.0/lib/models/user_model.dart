import 'package:supabase_flutter/supabase_flutter.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? role;
  final String? profileImageUrl;
  final String? phoneNumber;
  final String? phone;
  final String? address;
  final String? city;
  final String? country;
  final DateTime? joinDate;
  final int? totalRequests;
  final int? completedRequests;
  final double? rating;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    this.profileImageUrl,
    this.phoneNumber,
    this.phone,
    this.address,
    this.city,
    this.country,
    this.joinDate,
    this.totalRequests,
    this.completedRequests,
    this.rating,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'],
      profileImageUrl: json['ProfileImageUrl'],
      phoneNumber: json['phoneNumber'],
      phone: json['phone'],
      address: json['address'],
      city: json['city'],
      country: json['country'],
      joinDate:
          json['joinDate'] != null ? DateTime.parse(json['joinDate']) : null,
      totalRequests: json['totalRequests'],
      completedRequests: json['completedRequests'],
      rating: json['rating']?.toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'profileImageUrl': profileImageUrl,
      'phoneNumber': phoneNumber,
      'phone': phone,
      'address': address,
      'city': city,
      'country': country,
      'joinDate': joinDate?.toIso8601String(),
      'totalRequests': totalRequests,
      'completedRequests': completedRequests,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromProfile(User user, Map<String, dynamic> profile) {
    final created = profile['created_at'];
    return UserModel(
      id: user.id,
      name: (profile['full_name'] ?? user.email ?? '').toString(),
      email: user.email ?? '',
      role: profile['role'],
      phone: profile['phone'] as String?,
      phoneNumber: profile['phone'] as String?,
      address: profile['address'] as String?,
      city: profile['city'] as String?,
      country: profile['country'] as String?,
      joinDate: created != null ? DateTime.tryParse(created.toString()) : null,
      totalRequests: profile['total_requests'] as int?,
      completedRequests: profile['completed_requests'] as int?,
      rating: profile['rating'] != null
          ? (profile['rating'] as num).toDouble()
          : null,
      profileImageUrl: profile['profile_image_url'] as String?,
      createdAt: created != null
          ? DateTime.tryParse(created.toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
