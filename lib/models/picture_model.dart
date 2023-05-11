import 'package:cloud_firestore/cloud_firestore.dart';

class PictureModel {
  final String recipeId;
  final String pictureUrl;
  final String userId;

  PictureModel(
      {required this.recipeId, required this.pictureUrl, required this.userId});

  factory PictureModel.fromJson(Map<String, dynamic> json) {
    return PictureModel(
        recipeId: json['recipeId'],
        pictureUrl: json['pictureUrl'],
        userId: json['userId']);
  }

  Map<String, dynamic> toJson() {
    return {
      'recipe_id': recipeId,
      'image_url': pictureUrl,
      'user_id': userId,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'recipeId': recipeId,
      'pictureUrl': pictureUrl,
      'userId': userId,
    };
  }

  static PictureModel fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return PictureModel(
      recipeId: data['recipeId'],
      userId: data['userId'],
      pictureUrl: data['pictureUrl'] ?? "",
    );
  }
}
