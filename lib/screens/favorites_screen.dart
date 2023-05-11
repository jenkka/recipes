import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipes/screens/recipe_detail_screen.dart';

import '../models/recipe_model.dart';
import '../providers/auth_provider.dart';
import '../providers/recipe_provider.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _isInitialized = false;

  Future<void> _refreshFavorites(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await Provider.of<RecipeProvider>(context, listen: false)
        .setFavorites(authProvider.user!.uid);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final recipeProvider = Provider.of<RecipeProvider>(context);

    if (!_isInitialized) {
      _refreshFavorites(context);
      _isInitialized = true;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 189, 89),
        title: Row(children: const [
          Text(
            "Cookie",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            "Cookie",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 255, 77, 136),
            ),
          ),
        ]),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _refreshFavorites(context),
              child: ListView.builder(
                itemCount: recipeProvider.favorites.length,
                itemBuilder: (BuildContext context, int index) {
                  RecipeModel recipe = recipeProvider.favorites[index];
                  return GestureDetector(
                    onTap: () {
                      recipeProvider.clearPictures();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RecipeDetailScreen(recipe: recipe),
                        ),
                      );
                    },
                    child: Card(
                      child: Stack(
                        children: [
                          ClipRRect(
                            child: Image.network(
                              recipe.imgUrl,
                              height: 150,
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: GestureDetector(
                              onTap: () {
                                recipeProvider.toggleFavorite(
                                    recipe, authProvider.user!.uid);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                ),
                                padding: const EdgeInsets.all(5),
                                child: Icon(
                                  recipe.isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: recipe.isFavorite
                                      ? Colors.pink
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            left: 10,
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.6),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Text(
                                recipe.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
