import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:recipe_demo_flutter/features/recipe/model/recipe.dart';
import 'package:recipe_demo_flutter/services/database_service.dart';

class RecipeDropdown extends StatelessWidget {
  final String? selectedRecipeId;
  final Function(Recipe? value) onChanged;
  final String label;

  const RecipeDropdown({
    super.key,
    required this.selectedRecipeId,
    required this.onChanged,
    this.label = 'Select a recipe',
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw 'User not logged in';

    return ValueListenableBuilder<Box<Recipe>>(
      valueListenable: DatabaseService.recipesBox.listenable(),
      builder: (context, box, _) {
        final recipes = box.values.where((r) => r.userId == user.uid).toList();
        final isDisabled = selectedRecipeId != null;

        return DropdownButtonFormField<String>(
          value: selectedRecipeId,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items: recipes.map((recipe) {
            return DropdownMenuItem<String>(
              value: recipe.id, // assuming `Recipe` has a unique `id`
              child: Text(recipe.title),
            );
          }).toList(),
          onChanged: isDisabled 
          ? null 
          : (value) {
            Recipe? selected;
            try {
              selected = recipes.firstWhere((r) => r.id == value);
            } catch (_) {
              selected = null;
            }
            onChanged(selected);
          },
        );
      },
    );
  }
}
