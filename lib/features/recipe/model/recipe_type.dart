// models/recipe_type.dart
import 'package:hive/hive.dart';

part 'recipe_type.g.dart';

@HiveType(typeId: 0)
class RecipeType {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String? icon;

  RecipeType({
    required this.id,
    required this.name,
    this.icon,
  });
}