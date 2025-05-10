// screens/add_edit_recipe_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:recipe_demo_flutter/features/recipe/model/recipe.dart';
import 'package:recipe_demo_flutter/features/recipe/model/recipe_type.dart';
import 'package:recipe_demo_flutter/services/database_service.dart';
import 'dart:io';

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
    
    // _selectedType = widget.recipe?.type.name.toString();
    
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
        title: Text(widget.recipe == null ? 'Add Recipe' : 'Edit Recipe'),
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
                validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
              ),
              SizedBox(height: 16),
              _buildTypeDropdown(),
              SizedBox(height: 16),
              Text('Ingredients', style: Theme.of(context).textTheme.titleLarge),
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
            ? Image.file(_imageFile!, height: 150, fit: BoxFit.cover)
            : widget.recipe?.imagePath != null
                ? Image.file(File(widget.recipe!.imagePath!), height: 150, fit: BoxFit.cover)
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
        
        return DropdownButtonFormField<RecipeType>(
          value:(widget.recipe != null && types.any((value) => value.name == widget.recipe!.type.name.toString())) ? widget.recipe!.type : null,
          items: types.map((type) => DropdownMenuItem<RecipeType>(
            value: type,
            child: Text(type.name),
          )).toList(),
          onChanged: (type) => setState(() => _selectedType = type),
          decoration: InputDecoration(
            labelText: 'Recipe Type',
            border: OutlineInputBorder(),
          ),
          validator: (value) => value == null ? 'Please select a type' : null,
        );
      },
    );
  }

  List<Widget> _buildIngredientFields() {
    return List<Widget>.generate(_ingredientControllers.length, (index) {
      return Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _ingredientControllers[index],
              decoration: InputDecoration(
                labelText: 'Ingredient ${index + 1}',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value!.isEmpty ? 'Please enter ingredient' : null,
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
            child: TextFormField(
              controller: _stepControllers[index],
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Step ${index + 1}',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value!.isEmpty ? 'Please enter step' : null,
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
    // print(_selectedType);
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
      );
      
      DatabaseService.recipesBox.put(recipe.id, recipe);
      context.pop(true);
      context.pop();

      Future.microtask(() {
        if(mounted){
          context.push(
            '/recipe-detail',
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