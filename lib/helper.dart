import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipe_demo_flutter/features/recipe/model/recipe.dart';
import 'package:recipe_demo_flutter/services/database_service.dart';

class Helper{
  static bool isUserLoggedIn() {
    return FirebaseAuth.instance.currentUser != null;
  }

  static Map<String, Map<String, Map<String, Recipe?>>> loadMealPlans() {
    final raw = DatabaseService.mealPlanBox.get('mealPlans');
    final Map<String, Map<String, Map<String, Recipe?>>> parsed = {};
    print(raw);
    if (raw is Map) {
      try {

        raw.forEach((week, dayMap) {
          if (dayMap is Map) {
            final convertedDays = <String, Map<String, Recipe?>>{};

            dayMap.forEach((day, meals) {
              if (meals is Map) {
                convertedDays[day.toString()] = meals.map((meal, value) =>
                  MapEntry(meal.toString(), value));
              }
            });

            parsed[week.toString()] = convertedDays;
          }
        });        
        
        return parsed;

      } catch (e) {
        print("Error parsing meal plans: $e");
      }
    } else {
      print('Unexpected data format: ${raw.runtimeType}');
    }
    return parsed;
  }
  
}