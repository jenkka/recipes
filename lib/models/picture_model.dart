import 'package:cloud_firestore/cloud_firestore.dart';

class PictureModel {
  final String recipeId;
  final String imageUrl;
  final String userId;
  final DateTime createdAt;

  PictureModel(
      {required this.recipeId,
      required this.imageUrl,
      required this.userId,
      required this.createdAt});

  factory PictureModel.fromJson(Map<String, dynamic> json) {
    return PictureModel(
      recipeId: json['recipe_id'],
      imageUrl: json['image_url'],
      userId: json['user_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipe_id': recipeId,
      'image_url': imageUrl,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'recipeId': recipeId,
      'imageUrl': imageUrl,
      'userId': userId,
      'createdAt': createdAt
    };
  }

  static PictureModel fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return PictureModel(
      recipeId: data['recipeId'],
      userId: data['userId'],
      imageUrl: data['imageUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
