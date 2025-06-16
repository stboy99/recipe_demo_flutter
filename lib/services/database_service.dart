// services/database_service.dart
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:recipe_demo_flutter/features/note/model/note.dart';
import '../features/recipe/model/recipe.dart';
import '../features/recipe/model/recipe_type.dart';
//3k

class DatabaseService {
  static Future<void> init() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    
    Hive.registerAdapter(RecipeTypeAdapter());
    Hive.registerAdapter(RecipeAdapter());
    Hive.registerAdapter(NoteAdapter());
    
    await Hive.openBox<RecipeType>('recipeTypes');
    await Hive.openBox<Recipe>('recipes');
    await Hive.openBox<Note>('note');
    await Hive.openBox('mealPlans');
  }

  static Box<RecipeType> get recipeTypesBox => Hive.box<RecipeType>('recipeTypes');
  static Box<Recipe> get recipesBox => Hive.box<Recipe>('recipes');
  static Box<Note> get  noteBox => Hive.box<Note>('note');
  static Box get mealPlanBox => Hive.box('mealPlans');
}