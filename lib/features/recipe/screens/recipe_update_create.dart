// screens/add_edit_recipe_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:recipe_demo_flutter/features/recipe/model/recipe.dart';
import 'package:recipe_demo_flutter/features/recipe/model/recipe_type.dart';
import 'package:recipe_demo_flutter/services/database_service.dart';
import 'dart:io';

import 'package:recipe_demo_flutter/validator.dart';

class AddEditRecipeScreen extends StatefulWidget {
  final Recipe? recipe;

  const AddEditRecipeScreen({super.key, this.recipe});

  @override
  _AddEditRecipeScreenState createState() => _AddEditRecipeScreenState();
}

class _AddEditRecipeScreenState extends State<AddEditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late RecipeType? _selectedType;
  File? _imageFile;
  final List<TextEditingController> _ingredientControllers = [];
  final List<TextEditingController> _stepControllers = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.recipe?.title ?? '');
    
    _selectedType = widget.recipe?.type;
    
    if (widget.recipe != null) {
      for (final ingredient in widget.recipe!.ingredients) {
        _ingredientControllers.add(TextEditingController(text: ingredient));
      }
      for (final step in widget.recipe!.steps) {
        _stepControllers.add(TextEditingController(text: step));
      }
    } else {
      _ingredientControllers.add(TextEditingController());
      _stepControllers.add(TextEditingController());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New Recipes',
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
            icon: Icon(Icons.save),
            onPressed: _saveRecipe,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImagePicker(),
              SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Recipe Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => TextValidator('Please enter recipe title').msg(value)
              ),
              SizedBox(height: 16),
              _buildTypeDropdown(),
              SizedBox(height: 16),
              Text('Ingredients', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 16),
              ..._buildIngredientFields(),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    _ingredientControllers.add(TextEditingController());
                  });
                },
              ),
              SizedBox(height: 16),
              Text('Steps', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 16),
              ..._buildStepFields(),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    _stepControllers.add(TextEditingController());
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        _imageFile != null
            ? Image.file(_imageFile!, height: 150, fit: BoxFit.cover, cacheWidth: 200, filterQuality: FilterQuality.medium,)
            : widget.recipe?.imagePath != null
                ? Image.file(File(widget.recipe!.imagePath!), height: 150, fit: BoxFit.cover, cacheWidth: 200, filterQuality: FilterQuality.medium,)
                : Container(
                    height: 150,
                    color: Colors.grey[200],
                    child: Icon(Icons.camera_alt, size: 50),
                  ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              icon: Icon(Icons.camera),
              label: Text('Camera'),
              onPressed: () => _pickImage(ImageSource.camera),
            ),
            TextButton.icon(
              icon: Icon(Icons.photo_library),
              label: Text('Gallery'),
              onPressed: () => _pickImage(ImageSource.gallery),
            ),
          ],
        ),
      ],
    );
  }

Widget _buildTypeDropdown() {
  return ValueListenableBuilder<Box<RecipeType>>(
    valueListenable: DatabaseService.recipeTypesBox.listenable(),
    builder: (context, box, _) {
      final types = box.values.toList();
      
      // Helper function to capitalize first letter
      String capitalize(String input) {
        if (input.isEmpty) return input;
        return input[0].toUpperCase() + input.substring(1);
      }

      // Get initial value with null checks
      RecipeType? initialValue;
      if (widget.recipe != null && widget.recipe!.type.name != null) {
        final recipeTypeName = widget.recipe!.type.name.toString();
        initialValue = types.firstWhere(
          (type) => type.name.toLowerCase() == recipeTypeName.toLowerCase(),
          orElse: () => types.first, // Fallback if not found
        );
      }

      return DropdownButtonFormField<RecipeType>(
        value: initialValue,
        items: types.map((type) => DropdownMenuItem<RecipeType>(
          value: type,
          child: Text(
            type.name.isNotEmpty 
              ? capitalize(type.name) 
              : 'Unnamed Type',
          ),
        )).toList(),
        onChanged: (type) => setState(() => _selectedType = type),
        decoration: const InputDecoration(
          labelText: 'Recipe Type',
          border: OutlineInputBorder(),
        ),
        validator: (value) => DynamicValidator('Please select recipe type').msg(value),
      );
    },
  );
}

  List<Widget> _buildIngredientFields() {
    return List<Widget>.generate(_ingredientControllers.length, (index) {
      return Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
              child: TextFormField(
                controller: _ingredientControllers[index],
                decoration: InputDecoration(
                  labelText: 'Ingredient ${index + 1}',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => TextValidator('Please enter ingredient').msg(value)
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.remove),
            onPressed: () {
              setState(() {
                _ingredientControllers.removeAt(index);
              });
            },
          ),
        ],
      );
    });
  }

  List<Widget> _buildStepFields() {
    return List<Widget>.generate(_stepControllers.length, (index) {
      return Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
              child: TextFormField(
                controller: _stepControllers[index],
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Step ${index + 1}',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => TextValidator('Please enter step').msg(value)
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.remove),
            onPressed: () {
              setState(() {
                _stepControllers.removeAt(index);
              });
            },
          ),
        ],
      );
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _saveRecipe() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');
    if (_formKey.currentState!.validate() && _selectedType != null) {
      final ingredients = _ingredientControllers
          .map((controller) => controller.text)
          .toList();
      final steps = _stepControllers
          .map((controller) => controller.text)
          .toList();
      
      final recipe = Recipe(
        id: widget.recipe?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        imagePath: _imageFile?.path ?? widget.recipe?.imagePath,
        type: _selectedType!,
        ingredients: ingredients,
        steps: steps,
        userId: user.uid
      );
      
      DatabaseService.recipesBox.put(recipe.id, recipe);
      context.pop(true);
      if(widget.recipe != null){
       context.pop();
      }
      Future.microtask(() {
        if(mounted){
          context.push(
            '/recipe-list/recipe-detail',
            extra: {'recipe': recipe},
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (final controller in _ingredientControllers) {
      controller.dispose();
    }
    for (final controller in _stepControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}