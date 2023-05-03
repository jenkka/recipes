import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeModel {
  final int id;
  final String title;
  final String imgUrl;
  final int servings;
  final int minutes;
  final double pricePerServing;
  final List<dynamic> dishTypes;
  final String summary;
  final String url;
  // final List<String> ingredients;
  // final List<String> steps;
  bool isFavorite;

  RecipeModel({
    required this.id,
    required this.title,
    required this.imgUrl,
    this.servings = 0,
    this.minutes = 0,
    this.pricePerServing = 0,
    this.dishTypes = const [],
    this.summary = "",
    this.url = "",
    // required this.ingredients,
    // required this.steps,
    this.isFavorite = false,
  });

  void toggleFavorite() {
    isFavorite = !isFavorite;
  }

  factory RecipeModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return RecipeModel(
      id: data['id'],
      title: data['title'],
      imgUrl: data['imgUrl'],
      servings: data['servings'],
      minutes: data['minutes'],
      pricePerServing: data['pricePerServing'],
      dishTypes: data['dishTypes'],
      summary: data['summary'],
      isFavorite: data['isFavorite'],
    );
  }

  @override
  String toString() {
    return title;
  }
}
