// screens/recipe_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_demo_flutter/features/recipe/model/recipe.dart';
import 'package:recipe_demo_flutter/helper.dart';
import 'package:recipe_demo_flutter/services/database_service.dart';
import 'dart:io';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  _RecipeDetailState createState() => _RecipeDetailState();
}

class _RecipeDetailState extends State<RecipeDetailScreen>{ 
  late bool isAssigned;
  bool checkIfRecipeAssigned(String targetId) {
    final mealPlan = Helper.loadMealPlans();

    for (final dayEntry in mealPlan.entries) {
      final meals = dayEntry.value;

      for (final recipe in meals.values) {
        for(final recipeInner in recipe.values){
          if (recipeInner != null && recipeInner.id == targetId) {
            return true;
          }
        }
      }
    }

    return false;
  }

  @override
  void initState(){
    super.initState();
    isAssigned = checkIfRecipeAssigned(widget.recipe.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.recipe.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          if(!isAssigned)...[
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => _navigateToEditRecipe(context),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteRecipe(context),
            ),
          ]
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.recipe.imagePath != null
                ? Image.file(File(widget.recipe.imagePath!), height: 200, width: double.infinity, fit: BoxFit.cover, cacheWidth: 200, filterQuality: FilterQuality.medium, )
                : Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: Center(child: Icon(Icons.fastfood, size: 100)),
                  ),
            SizedBox(height: 16),
            Text('Type: ${widget.recipe.type.name}', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 24),
            Text('Ingredients', style: Theme.of(context).textTheme.titleLarge),
            ...widget.recipe.ingredients.map((ingredient) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text('- $ingredient'),
            )),
            SizedBox(height: 24),
            Text('Steps', style: Theme.of(context).textTheme.titleLarge),
            ...widget.recipe.steps.asMap().entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Step ${entry.key + 1}', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(entry.value),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _navigateToEditRecipe(BuildContext context) {
    context.push('/recipe-list/recipe-update-create', extra: {'recipe': widget.recipe});
  }

  void _deleteRecipe(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Delete Recipe'),
        content: Text('Are you sure you want to delete this recipe?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => context.pop(true),
          ),
          TextButton(
            child: Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () {
              DatabaseService.recipesBox.delete(widget.recipe.id);
              context.pop();
              context.pop();
            },
          ),
        ],
      ),
    );
  }
}