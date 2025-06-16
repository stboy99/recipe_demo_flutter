import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_demo_flutter/helper.dart';
import 'package:recipe_demo_flutter/services/database_service.dart';
import 'package:recipe_demo_flutter/widget/inkwell_button.dart';

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
  bool _isLogin = false;
  late final StreamSubscription<User?> _authSubscription;

  @override
  void dispose() {
    _nameController.dispose();
    _authSubscription.cancel();
    super.dispose();
  }
  @override
  void initState(){
    super.initState();
    _isLogin = Helper.isUserLoggedIn();

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _isLogin = user != null;
      });
    });
  }

  Future<void> _signInAnonymously() async {
    setState(() => _isLoading = true);
    if(_isLoading){
      showLoading();
    }
    try {
      await FirebaseAuth.instance.signInAnonymously();
      Future.delayed(Duration(milliseconds: 190));
      if(FirebaseAuth.instance.currentUser != null){
        await FirebaseAuth.instance.currentUser!.updateDisplayName(_nameController.text);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing in: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        context.pop();
      }
    }
  }


  void showLoading(){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
void showSorryDialog(){
      if (mounted) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Sorry!'),
        content: Text('This is a demo version, and data will be clear upon signout. We are making our way to the feature!'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => context.pop(true),
          ),
          TextButton(
            child: Text('yes proceed', style: TextStyle(color: Colors.red)),
            onPressed: () {
              _signOut();
            },
          ),
        ],
      ),
    );
    }
}
Future<void> _signOut() async {
  context.pop();
  _nameController.text = '';
  setState(() => _isLoading = true);
  if(_isLoading){
    showLoading();
  }
  try {

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
      context.pop();
    }
  }
}

Future<void> _clearLocalDatabase() async {
  try {
    await DatabaseService.recipesBox.clear();
    await DatabaseService.mealPlanBox.clear();
    await DatabaseService.noteBox.clear();
  } catch (e) {
    debugPrint('Failed to clear Hive boxes: $e');
  }
}




  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade100, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                FirebaseAuth.instance.currentUser == null
                    ? '👋 Welcome!'
                    : '👨‍🍳 Welcome, ${FirebaseAuth.instance.currentUser!.displayName}!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade700,
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
              InkwellButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        if (FirebaseAuth.instance.currentUser == null) {
                          if (_nameController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Can I get your beautiful name?')),
                            );
                            return;
                          }
                          _signInAnonymously();
                        } else {
                          context.go('/recipe-list');
                        }
                      }, 
                  title: _isLoading ? 'Loading...' : 'Get Started'
              ),
              const SizedBox(height: 16),
              if(FirebaseAuth.instance.currentUser != null)
              TextButton(
                onPressed: _isLoading ? null : showSorryDialog,
                child: const Text(
                  'No byebye!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: _buildWelcomeCard(),
          ),
        ),
      ),
      floatingActionButton: _isLogin && mounted ?  FloatingActionButton(
        onPressed: () {
          context.push('/meal-plan');
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.lock_clock, color: Colors.white,),
      ): null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Position
    );
  }
}