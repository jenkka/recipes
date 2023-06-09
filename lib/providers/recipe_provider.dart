import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:recipes/models/recipe_model.dart';

import '../models/picture_model.dart';

class RecipeProvider extends ChangeNotifier {
  List<PictureModel> _pictures = [];

  List<PictureModel> get pictures => _pictures;
  List<RecipeModel> recipes = [];
  List<RecipeModel> favorites = [];
  List<RecipeModel> filteredRecipes = [];
  TextEditingController textEditingController = TextEditingController();
  final CollectionReference<Map<String, dynamic>> _favoritesCollection =
      FirebaseFirestore.instance.collection('favorites');
  final CollectionReference<Map<String, dynamic>> _picturesCollection =
      FirebaseFirestore.instance.collection('pictures');

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

    // print(recipe);

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
    print("getting recipe details...");
    String url = '$apiUrl/${id.toString()}/information';
    Uri uri = Uri.parse(url);
    // print(url);
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

    print("Loading pictures");
    loadPictures(id.toString());
    print("Loaded pictures!");

    return recipe;
  }

  Future<void> setFavorites(String userId) async {
    // print("Setting favorites");
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

  void clearPictures() {
    _pictures = [];
  }

  Future<void> loadPictures(String recipeId) async {
    print("Loading pictures");
    // _pictures.clear();
    final pictures = await FirebaseFirestore.instance
        .collection('pictures')
        .where('recipeId', isEqualTo: recipeId)
        .get();
    print("got pictures from firebase");
    for (var document in pictures.docs) {
      print(document.data());
    }
    _pictures =
        pictures.docs.map((doc) => PictureModel.fromJson(doc.data())).toList();

    print("Loaded pictures!");
  }

  Future<void> savePictureFromCamera(String recipeId, String userId) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileName = path.basename(file.path);
      final ref = FirebaseStorage.instance
          .ref()
          .child('recipePictures')
          .child(fileName);
      final task = ref.putFile(file);
      await task.whenComplete(() async {
        final pictureUrl = await ref.getDownloadURL();
        await _picturesCollection.add({
          'recipeId': recipeId,
          'userId': userId,
          'pictureUrl': pictureUrl,
          'createdAt': DateTime.now()
        });
        pictures.add(PictureModel(
            recipeId: recipeId, userId: userId, pictureUrl: pictureUrl));
        notifyListeners();
      });
    }
  }

  Future<void> savePicture(String recipeId, String userId) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileName = path.basename(file.path);
      final ref = FirebaseStorage.instance
          .ref()
          .child('recipePictures')
          .child(recipeId)
          .child(fileName);
      final task = ref.putFile(file);
      await task.whenComplete(() async {
        final pictureUrl = await ref.getDownloadURL();
        await _picturesCollection.add({
          'recipeId': recipeId,
          'userId': userId,
          'pictureUrl': pictureUrl,
          'createdAt': DateTime.now()
        });
        pictures.add(PictureModel(
            recipeId: recipeId, userId: userId, pictureUrl: pictureUrl));
        notifyListeners();
      });
    }
  }

  void reset() {
    recipes = [];
    favorites = [];
    _pictures = [];
    textEditingController.text = "";
  }
}
