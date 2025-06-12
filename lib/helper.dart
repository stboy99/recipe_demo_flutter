import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:recipe_demo_flutter/api.dart';
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

  Future<Position> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> locateNearbyStores() async {
    final position = await getCurrentLocation();
    final stores = await fetchNearbyGroceryStores(
      lat: position.latitude,
      lng: position.longitude,
      apiKey: 'YOUR_GOOGLE_PLACES_API_KEY',
    );

    for (final store in stores) {
      print('🛒 ${store['name']} — ${store['vicinity']}');
    }
  }
  
}