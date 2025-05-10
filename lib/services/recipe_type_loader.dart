
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:recipe_demo_flutter/features/recipe/model/recipe_type.dart';
import 'package:recipe_demo_flutter/services/database_service.dart';

class RecipeTypeLoader {
  static Future<void> loadRecipeTypesFromJson() async {
    final jsonString = await rootBundle.loadString('assets/recipetypes.json');
    final jsonData = json.decode(jsonString) as List;
    
    final recipeTypesBox = DatabaseService.recipeTypesBox;
    
    for (final typeData in jsonData) {
      final recipeType = RecipeType(
        id: typeData['id'],
        name: typeData['name'],
        icon: typeData['icon'],
      );
      
      await recipeTypesBox.put(recipeType.id, recipeType);
    }
  }
}