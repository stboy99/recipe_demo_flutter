// screens/recipe_list_screen.dart
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:recipe_demo_flutter/features/recipe/model/recipe_type.dart';
import 'package:recipe_demo_flutter/features/recipe/model/recipe.dart';
import 'package:recipe_demo_flutter/features/recipe/screens/recipe_detail_screen.dart';
import 'package:recipe_demo_flutter/features/recipe/screens/recipe_update_create.dart';
import 'package:recipe_demo_flutter/services/database_service.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  _RecipeListScreenState createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  RecipeType? _selectedType;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recipes',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _navigateToAddRecipe(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            color: Colors.deepPurple.shade50,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children:[ 
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      '👋 Hello, ${FirebaseAuth.instance.currentUser?.displayName ?? 'Chef'}!',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(height: 20,),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 390) {
                        // Stack vertically on narrow screens
                        return Column(
                          children: [
                            _buildTypeDropdown(),
                            SizedBox(height: 10),
                            TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                labelText: 'Search',
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ],
                        );
                      } else {
                        // Use row layout for wider screens
                        return Row(
                          children: [
                            Expanded(child: _buildTypeDropdown()),
                            SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  labelText: 'Search',
                                  prefixIcon: Icon(Icons.search),
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  )
                ]
              ),
            ),
          ),
          Expanded(
            child: _buildRecipeList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return ValueListenableBuilder<Box<RecipeType>>(
      valueListenable: DatabaseService.recipeTypesBox.listenable(),
      builder: (context, box, _) {
        final types = box.values.toList();
        
        return DropdownButtonFormField<RecipeType>(
          value: _selectedType,
          items: [
            DropdownMenuItem<RecipeType>(
              value: null,
              child: Text('All Types'),
            ),
            ...types.map((type) => DropdownMenuItem<RecipeType>(
              value: type,
              child: Text(type.name),
            )),
          ],
          onChanged: (type) => setState(() => _selectedType = type),
          decoration: InputDecoration(
            labelText: 'Filter by Type',
            border: OutlineInputBorder(),
          ),
        );
      },
    );
  }

  Widget _buildRecipeList() {
      final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw 'user not login';
    return ValueListenableBuilder<Box<Recipe>>(
      valueListenable: DatabaseService.recipesBox.listenable(),
      builder: (context, box, _) {
        final recipes = box.values.toList();
        
        var filteredRecipes = recipes.where((recipe) {
          recipe.userId == user.uid;
          final matchesType = _selectedType == null || 
              recipe.type.id == _selectedType!.id;
          final matchesSearch = _searchController.text.isEmpty ||
              recipe.title.toLowerCase().contains(_searchController.text.toLowerCase());
          return matchesType && matchesSearch;
        }).toList();
        if(filteredRecipes.isEmpty){
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sentiment_dissatisfied, size: 48, color: Colors.grey),
                SizedBox(height: 12),
                Text('No recipes yet...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                SizedBox(height: 4),
                Text('Why don’t you add some?', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );

        }
        return ListView.builder(
          itemCount: filteredRecipes.length,
          itemBuilder: (context, index) {
            final recipe = filteredRecipes[index];
            return ListTile(
              leading: recipe.imagePath != null 
                  ? Image.file(File(recipe.imagePath!), width: 50, height: 50, fit: BoxFit.cover)
                  : Icon(Icons.fastfood, size: 50),
              title: Text(recipe.title),
              subtitle: Text(recipe.type.name),
              onTap: () => _navigateToRecipeDetail(context, recipe),
            );
          },
        );
      },
    );
  }

  void _navigateToAddRecipe(BuildContext context) {
    context.push('/recipe-list/recipe-update-create');
  }

  void _navigateToRecipeDetail(BuildContext context, Recipe recipe) {
    context.push('/recipe-list/recipe-detail', extra: {'recipe': recipe});
  }
}