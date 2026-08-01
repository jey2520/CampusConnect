import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String title;
  final double price;
  final bool negotiable;
  final String condition;
  final String category;
  final String college;
  final String description;
  final String image;
  final List<String> images;
  final String sellerUid;
  final String sellerName;
  final String sellerRating;
  final String sellerInitials;
  final String status;
  final int views;
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.negotiable,
    required this.condition,
    required this.category,
    required this.college,
    required this.description,
    required this.image,
    required this.images,
    required this.sellerUid,
    required this.sellerName,
    required this.sellerRating,
    required this.sellerInitials,
    required this.status,
    required this.views,
    required this.createdAt,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map, String docId) {
    return ProductModel(
      id: docId,
      title: map['title'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      negotiable: map['negotiable'] ?? false,
      condition: map['condition'] ?? '',
      category: map['category'] ?? '',
      college: map['college'] ?? '',
      description: map['description'] ?? '',
      image: map['image'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      sellerUid: map['sellerUid'] ?? '',
      sellerName: map['sellerName'] ?? '',
      sellerRating: map['sellerRating'] ?? '5.0',
      sellerInitials: map['sellerInitials'] ?? 'CC',
      status: map['status'] ?? 'active',
      views: map['views'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'price': price,
      'negotiable': negotiable,
      'condition': condition,
      'category': category,
      'college': college,
      'description': description,
      'image': image,
      'images': images,
      'sellerUid': sellerUid,
      'sellerName': sellerName,
      'sellerRating': sellerRating,
      'sellerInitials': sellerInitials,
      'status': status,
      'views': views,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
