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

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  final User? user = FirebaseAuth.instance.currentUser;
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;
  bool _isLogin = false;
  late final StreamSubscription<User?> _authSubscription;

  late final AnimationController _fadeController;

  final List<String> _tips = [
    '🍎 An apple a day keeps the doctor away!',
    '💧 Don’t forget to drink water!',
    '👨‍🍳 Cooking is love made visible.',
    '🌈 Bright colors, bright day!',
  ];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _isLogin = Helper.isUserLoggedIn();

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _isLogin = user != null;
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _nameController.dispose();
    _authSubscription.cancel();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  String _getTipOfTheDay() {
    return _tips[DateTime.now().day % _tips.length];
  }

  Future<void> _signInAnonymously() async {
    setState(() => _isLoading = true);
    showLoading();

    try {
      await FirebaseAuth.instance.signInAnonymously();
      await Future.delayed(const Duration(milliseconds: 200));
      if (FirebaseAuth.instance.currentUser != null) {
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

  void showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  void showSorryDialog() {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Sorry!'),
          content: const Text(
              'This is a demo version, and data will be clear upon signout. We are making our way to the feature!'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => context.pop(true),
            ),
            TextButton(
              child: const Text('Yes proceed', style: TextStyle(color: Colors.red)),
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
    showLoading();

    try {
      await _clearLocalDatabase();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.isAnonymous) {
        await user.delete();
      }
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
    final name = FirebaseAuth.instance.currentUser?.displayName ?? 'friend';
    final greeting = _getGreeting();

    return FadeTransition(
      opacity: _fadeController,
      child: Card(
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
                      : '$greeting, $name!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _getTipOfTheDay(),
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                  textAlign: TextAlign.center,
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
                    title: _isLoading ? 'Loading...' : 'Start Plan Your Meal Now!'),
                const SizedBox(height: 16),
                if (FirebaseAuth.instance.currentUser != null)
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
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.fastfood, size: 32),
          tooltip: 'Go to Recipes',
          onPressed: () => context.go('/recipe-list'),
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.checkroom, size: 32),
          tooltip: 'Pick Outfit',
          onPressed: () => context.go('/color'),
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.lock_clock, size: 32),
          tooltip: 'Meal Plan',
          onPressed: () => context.push('/meal-plan'),
        ),
      ],
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
            child: Column(
              children: [
                _buildWelcomeCard(),
                if(Helper.isUserLoggedIn())...[
                  const SizedBox(height: 20),
                  Text(
                    'Pick me plan!!',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 5),
                  _buildQuickActions(),
                ]
                
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _isLogin
          ? FloatingActionButton(
              onPressed: () => context.push('/meal-plan'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              tooltip: 'Plan your meals!',
              child: const Icon(Icons.lock_clock, color: Colors.white),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
