// models/recipe.dart
import 'package:hive/hive.dart';
import 'package:recipe_demo_flutter/features/recipe/model/recipe_type.dart';

part 'recipe.g.dart';

@HiveType(typeId: 1)
class Recipe {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String? imagePath;
  
  @HiveField(3)
  final RecipeType type;
  
  @HiveField(4)
  final List<String> ingredients;
  
  @HiveField(5)
  final List<String> steps;
  
  @HiveField(6)
  final DateTime createdAt;

  Recipe({
    required this.id,
    required this.title,
    this.imagePath,
    required this.type,
    required this.ingredients,
    required this.steps,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}