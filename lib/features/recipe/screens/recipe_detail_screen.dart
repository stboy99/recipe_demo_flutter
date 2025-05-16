// screens/recipe_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:recipe_demo_flutter/features/recipe/model/recipe.dart';
import 'package:recipe_demo_flutter/features/recipe/screens/recipe_update_create.dart';
import 'package:recipe_demo_flutter/global_structure.dart';
import 'package:recipe_demo_flutter/services/database_service.dart';
import 'dart:io';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return GlobalStructure(
      title: recipe.title,
     body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            recipe.imagePath != null
                ? Image.file(File(recipe.imagePath!), height: 200, width: double.infinity, fit: BoxFit.cover)
                : Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: Center(child: Icon(Icons.fastfood, size: 100)),
                  ),
            SizedBox(height: 16),
            Text('Type: ${recipe.type.name}', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 24),
            Text('Ingredients', style: Theme.of(context).textTheme.titleLarge),
            ...recipe.ingredients.map((ingredient) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text('- $ingredient'),
            )),
            SizedBox(height: 24),
            Text('Steps', style: Theme.of(context).textTheme.titleLarge),
            ...recipe.steps.asMap().entries.map((entry) => Padding(
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
    context.push('/recipe-update-create', extra: {'recipe': recipe});
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
              DatabaseService.recipesBox.delete(recipe.id);
              context.pop();
              context.pop();
            },
          ),
        ],
      ),
    );
  }
}