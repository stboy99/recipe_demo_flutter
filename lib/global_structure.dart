import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GlobalStructure extends StatefulWidget {
  final String title;
  final StatefulNavigationShell navigationShell;
  // final Widget body;
  
  final Widget? action;

  const GlobalStructure({
    super.key,
    required this.title,
    required this.navigationShell,
    // required this.body,
    this.action
  });

  @override
  State<GlobalStructure> createState() => _GlobalStructureState();
}


class _GlobalStructureState extends State<GlobalStructure>{
  bool _isLogin = false;
  late final StreamSubscription<User?> _authSubscription;

  @override
  void initState() {
    super.initState();
    _isLogin = FirebaseAuth.instance.currentUser != null;

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _isLogin = user != null;
      });
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.transparent,
            expandedHeight: 70,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints){
                final top = constraints.biggest.height;
                final isCollapsed = top <= kToolbarHeight + 10;
                return Container(
                  decoration: BoxDecoration(
                    color: isCollapsed ? Colors.white.withOpacity(0.95) : Colors.transparent,
                    boxShadow: isCollapsed ? [BoxShadow(color: Colors.black26, blurRadius: 4)] : [],
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child:Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          )
                        ],
                      ),
                    )
                  )
                );
              }
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(16.0),
            sliver: SliverList(delegate: SliverChildListDelegate([widget.navigationShell]) ),
          )
        ],
      ), 
      bottomNavigationBar: _isLogin && mounted ? 
      BottomNavigationBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.blueGrey,
          selectedItemColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(
            fontSize: 12, // Set selected label size here
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 10, // Set unselected label size here
            fontWeight: FontWeight.w400,
          ),
          items:<BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu),
              label: 'Recipes',
            ),
          ],
          currentIndex: widget.navigationShell.currentIndex,
          onTap: (int index) => _onTap(context, index),
        
      ) : null,
    );
  }

  void _onTap(BuildContext context, int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: true,
    );
  }
}
