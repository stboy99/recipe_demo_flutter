import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:recipe_demo_flutter/features/homepage.dart';
import 'package:recipe_demo_flutter/firebase_options.dart';
import 'package:recipe_demo_flutter/routing.dart';
import 'package:recipe_demo_flutter/services/database_service.dart';
import 'package:recipe_demo_flutter/services/recipe_type_loader.dart';

Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.init();
  await RecipeTypeLoader.loadRecipeTypesFromJson();
    await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
//2:50pm, 10/5/25

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'Recipe Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
    );
  }
}
