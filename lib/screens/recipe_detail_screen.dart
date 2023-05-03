import 'package:flutter/material.dart';
import 'package:recipes/models/recipe_model.dart';
import 'package:recipes/providers/auth_provider.dart';
import 'package:recipes/providers/recipe_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:recipes/models/picture_model.dart';

class RecipeDetailScreen extends StatelessWidget {
  final RecipeModel recipe;

  const RecipeDetailScreen({Key? key, required this.recipe}) : super(key: key);

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
            icon: const Icon(Icons.share),
            onPressed: () async {
              await FlutterShare.share(
                title: recipe.title,
                text: recipe.summary,
                linkUrl: recipe.url,
                chooserTitle: 'Share Recipe',
              );
            },
          )
        ],
      ),
      body: FutureBuilder<RecipeModel>(
        future: recipeProvider.getRecipeDetails(recipe.id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            RecipeModel recipe = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    recipe.imgUrl,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              await launchUrl(Uri.parse(recipe.url));
                            },
                            child: const Text('Go to recipe'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Html(data: recipe.summary),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Pictures from users',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder<List<PictureModel>>(
                    future: recipeProvider.getPictures(recipe.id.toString()),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<PictureModel> pictures = snapshot.data!;
                        return SizedBox(
                          height: 150,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: pictures.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.network(
                                  pictures[index].imageUrl,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        );
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      recipeProvider.savePicture(
                          recipe.id.toString(), authProvider.user!.uid);
                    },
                    child: const Text('Upload Picture'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
