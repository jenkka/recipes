import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:recipes/models/recipe_model.dart';

class RecipeProvider extends ChangeNotifier {
  List<RecipeModel> recipes = <RecipeModel>[];
  List<RecipeModel> favorites = <RecipeModel>[];
  List<RecipeModel> filteredRecipes = <RecipeModel>[];
  TextEditingController textEditingController = TextEditingController();
  final CollectionReference<Map<String, dynamic>> _favoritesCollection =
      FirebaseFirestore.instance.collection('favorites');

  String apiKey = 'fe521415f74b4d33894db931c25b0d60';
  String apiUrl = 'https://api.spoonacular.com/recipes/';

  bool isLoading = false;

  Future<void> getRecipes() async {
    isLoading = true;
    notifyListeners();

    String url = '${apiUrl}complexSearch?query=${textEditingController.text}';
    Uri uri = Uri.parse(url);

    var response = await http.get(uri, headers: {'x-api-key': apiKey});
    Map<String, dynamic> jsonData = jsonDecode(response.body);

    recipes = [];
    jsonData['results'].forEach((e) {
      RecipeModel rp = RecipeModel(
        id: e['id'],
        title: e['title'],
        imgUrl: e['image'],
      );
      recipes.add(rp);
    });

    await _updateFavoritesStatus();
    isLoading = false;
    notifyListeners();
  }

  Future<void> toggleFavorite(RecipeModel recipe, String uid) async {
    String recipeId = recipe.id.toString();
    DocumentReference<Map<String, dynamic>> docRef =
        _favoritesCollection.doc(recipeId);
    DocumentSnapshot<Map<String, dynamic>> snapshot = await docRef.get();

    isLoading = true;
    notifyListeners();

    print(recipe);

    if (snapshot.exists) {
      await docRef.delete();
      for (int i = 0; i < favorites.length; i++) {
        if (favorites[i].id == recipe.id) {
          favorites.removeAt(i);
        }
      }
    } else {
      await docRef.set({
        "recipeId": int.parse(recipeId),
        "uid": uid.toString(),
        "title": recipe.title,
        "imgUrl": recipe.imgUrl,
        "servings": recipe.servings,
        "minutes": recipe.minutes,
        "pricePerServing": recipe.pricePerServing,
        "dishTypes": recipe.dishTypes,
        "summary": recipe.summary,
        "url": recipe.url
      });
      favorites.add(recipe);
    }

    await _updateFavoritesStatus();
    isLoading = false;
    notifyListeners();
  }

  Future<void> _updateFavoritesStatus() async {
    for (int i = 0; i < recipes.length; i++) {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _favoritesCollection.doc(recipes[i].id.toString()).get();
      if (snapshot.exists) {
        recipes[i].isFavorite = true;
      } else {
        recipes[i].isFavorite = false;
      }
    }
    notifyListeners();
  }

  Future<RecipeModel> getRecipeDetails(int id) async {
    String url = '$apiUrl/${id.toString()}/information';
    Uri uri = Uri.parse(url);
    print(url);
    var response = await http.get(uri, headers: {'x-api-key': apiKey});
    Map<String, dynamic> jsonData = jsonDecode(response.body);

    RecipeModel recipe = RecipeModel(
        id: jsonData['id'],
        title: jsonData['title'],
        imgUrl: jsonData['image'],
        servings: jsonData['servings'],
        minutes: jsonData['readyInMinutes'],
        pricePerServing: jsonData['pricePerServing'],
        dishTypes: jsonData['dishTypes'],
        summary: jsonData['summary'],
        url: jsonData['sourceUrl']);

    return recipe;
  }

  Future<void> setFavorites(String userId) async {
    print("Setting favorites");
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('favorites')
          .where('uid', isEqualTo: userId)
          .get();

      favorites = [];
      for (DocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

        RecipeModel newRecipe = RecipeModel(
            id: data!['recipeId'],
            title: data['title'],
            imgUrl: data['imgUrl'],
            isFavorite: true);
        favorites.add(newRecipe);
      }

      notifyListeners();
    } catch (e) {
      print('Error getting favorites: $e');
    }
  }

  Future<List<String>> getPictures(int recipeId) async {
    // TODO: Fix. Also, show images section in details and add a button to upload a picture.
    List<String> pictureUrls = [];

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('pictures')
              .where('recipeId', isEqualTo: recipeId)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (DocumentSnapshot<Map<String, dynamic>> snapshot
            in querySnapshot.docs) {
          Map<String, dynamic>? data = snapshot.data();

          if (data != null && data.containsKey('url')) {
            pictureUrls.add(data['url']);
          }
        }
      }
    } catch (e) {
      print('Error getting pictures: $e');
    }

    return pictureUrls;
  }

  void savePicture(int recipeId) {
    // TODO: Create
  }
}
