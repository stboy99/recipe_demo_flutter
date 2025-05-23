// services/database_service.dart
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../features/recipe/model/recipe.dart';
import '../features/recipe/model/recipe_type.dart';

class DatabaseService {
  static Future<void> init() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    
    Hive.registerAdapter(RecipeTypeAdapter());
    Hive.registerAdapter(RecipeAdapter());
    
    await Hive.openBox<RecipeType>('recipeTypes');
    await Hive.openBox<Recipe>('recipes');
  }

  static Box<RecipeType> get recipeTypesBox => Hive.box<RecipeType>('recipeTypes');
  static Box<Recipe> get recipesBox => Hive.box<Recipe>('recipes');
}