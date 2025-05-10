import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:recipe_demo_flutter/features/recipe/model/recipe.dart';
import 'package:recipe_demo_flutter/features/recipe/screens/recipe_list_screen.dart';
import 'package:recipe_demo_flutter/global_structure.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _signInAnonymously() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInAnonymously();
      if(user != null && _nameController.text.isNotEmpty){
        await user!.updateDisplayName(_nameController.text);
      }
      // if (mounted) {
      //   context.push('/recipe-list');
      // }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing in: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

Future<void> _signOut() async {
  setState(() => _isLoading = true);
  try {
    // Show feature in progress message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sorry, by signout all data will be clear, storing by account feature incoming!!')),
      );
    }

    await _clearLocalDatabase();

    // Handle anonymous user deletion
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.isAnonymous) {
      await user.delete();
    }

    // Sign out
    await FirebaseAuth.instance.signOut();
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: ${e.toString()}')),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

Future<void> _clearLocalDatabase() async {
  try {
    // Assuming the boxes are already opened elsewhere in your app
    final recipesBox = Hive.box<Recipe>('recipes');
    // final settingsBox = Hive.box('recipeTypes');

    await recipesBox.clear();
    // await settingsBox.clear();
  } catch (e) {
    debugPrint('Failed to clear Hive boxes: $e');
  }
}




  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              (FirebaseAuth.instance.currentUser == null) ? 'Welcome!' : 'Welcome! ${FirebaseAuth.instance.currentUser!.displayName}',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (FirebaseAuth.instance.currentUser == null)
              const Text(
                "Kindly Enter Your Name To Get Started!",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              )
            else
              const Column(
                children: [
                  Text(
                    "Don't know what to eat?",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Enter to create your desired recipe now!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            const SizedBox(height: 24),
            if (FirebaseAuth.instance.currentUser == null)
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Your Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      if (FirebaseAuth.instance.currentUser == null) {
                        if(_nameController.text.isEmpty){
                                ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Can i get your beautiful name?')),
                            );
                            return;
                        }
                        _signInAnonymously();
                      } else {
                        context.push('/recipe-list');
                      }
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    )
                  : const Text(
                      'Get Started',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
            const SizedBox(height: 16),
            if(FirebaseAuth.instance.currentUser != null)
              TextButton(
                onPressed: _isLoading ? null : _signOut,
                child: const Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red,
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlobalStructure(
      title: widget.title,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: _buildWelcomeCard(),
          ),
        ),
      ),
    );
  }
}