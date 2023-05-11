import 'package:flutter/material.dart';
import 'package:recipes/providers/auth_provider.dart';
import 'package:recipes/providers/recipe_provider.dart';
import 'package:provider/provider.dart';
import 'package:recipes/models/recipe_model.dart';
import 'package:recipes/screens/recipe_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.signOut();
              recipeProvider.reset();
              Navigator.of(context).pushReplacementNamed('/');
            },
          )
        ],
      ),
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: recipeProvider.textEditingController,
                          decoration: InputDecoration(
                            hintText: "Search for something",
                            hintStyle: TextStyle(
                              fontSize: 18,
                              color: Colors.black.withOpacity(0.5),
                              fontWeight: FontWeight.bold,
                            ),
                            suffixIcon: InkWell(
                              onTap: () {
                                recipeProvider.getRecipes();
                              },
                              child: const Icon(
                                Icons.search,
                                color: Colors.black,
                                size: 28,
                              ),
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                          onSubmitted: (_) {
                            recipeProvider.getRecipes();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: recipeProvider.getRecipes,
                    child: ListView.builder(
                      itemCount: recipeProvider.recipes.length,
                      itemBuilder: (BuildContext context, int index) {
                        RecipeModel recipe = recipeProvider.recipes[index];

                        return GestureDetector(
                          onTap: () {
                            recipeProvider.clearPictures();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      RecipeDetailScreen(recipe: recipe)),
                            );
                          },
                          child: Card(
                            child: Stack(
                              children: [
                                ClipRRect(
                                  child: Image.network(
                                    recipeProvider.recipes[index].imgUrl,
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
                                        recipe,
                                        authProvider.user!.uid,
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.white,
                                      ),
                                      padding: const EdgeInsets.all(5),
                                      child: Icon(
                                        recipeProvider.recipes[index].isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: recipeProvider
                                                .recipes[index].isFavorite
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
                                      recipeProvider.recipes[index].title,
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
                ),
              ],
            ),
          ),
          recipeProvider.isLoading
              ? Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ))
              : Container()
        ],
      ),
    );
  }
}
