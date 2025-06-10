import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_demo_flutter/features/homepage.dart';
import 'package:recipe_demo_flutter/features/plan/screen/mealslot.dart';
import 'package:recipe_demo_flutter/features/recipe/screens/recipe_detail_screen.dart';
import 'package:recipe_demo_flutter/features/recipe/screens/recipe_list_screen.dart';
import 'package:recipe_demo_flutter/features/recipe/screens/recipe_update_create.dart';
import 'package:recipe_demo_flutter/global_structure.dart';

final _shellNavigatorKey = GlobalKey<NavigatorState>();
final GoRouter router = GoRouter(
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (BuildContext context, GoRouterState state,
          StatefulNavigationShell navigationShell) {
            return GlobalStructure(
              title: '', 
              navigationShell: navigationShell,
            );
          },
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          navigatorKey: _shellNavigatorKey,
          routes: <RouteBase>[
            GoRoute(
              path: '/',
              builder: (BuildContext context, GoRouterState state) {
                // final args = state.extra as Map<String, dynamic>;
                return MyHomePage(title: 'Home',);
              },
              routes: <RouteBase>[
                GoRoute(
                  path: 'meal-plan',
                  builder: (BuildContext context, GoRouterState state) {
                    return MealCalendarScreen();
                  },
                ),
              ]
            ),
          ]
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/recipe-list',
              builder: (BuildContext context, GoRouterState state) {
                return const RecipeListScreen();
              },    
              routes: <RouteBase>[
                GoRoute(
                  path: 'recipe-detail',
                  builder: (BuildContext context, GoRouterState state) {
                    final args = state.extra as Map<String, dynamic>;
                    return RecipeDetailScreen(recipe: args['recipe'],);
                  },
                ),
                GoRoute(
                  path: 'recipe-update-create',
                  builder: (BuildContext context, GoRouterState state) {
                    final args = state.extra as Map<String, dynamic>?;
                    if(args != null){
                      return AddEditRecipeScreen(recipe: args['recipe'],);
                    }
                    return AddEditRecipeScreen();
                  },
                ),
              ],
            ),
          ]
        )
      ]
      ),
          
      ],
    );
    // GoRoute(
    //   path: '/',
    //   builder: (BuildContext context, GoRouterState state) {
    //     // final args = state.extra as Map<String, dynamic>;
    //     return MyHomePage(title: 'Home',);
    //   },
    // ),
    // GoRoute(
    //   path: 'recipe-list',
    //   builder: (BuildContext context, GoRouterState state) {
    //     return const RecipeListScreen();
    //   },    
    //   routes: <RouteBase>[
    //     GoRoute(
    //       path: 'recipe-detail',
    //       builder: (BuildContext context, GoRouterState state) {
    //         final args = state.extra as Map<String, dynamic>;
    //         return RecipeDetailScreen(recipe: args['recipe'],);
    //       },
    //     ),
    //     GoRoute(
    //       path: 'recipe-update-create',
    //       builder: (BuildContext context, GoRouterState state) {
    //         final args = state.extra as Map<String, dynamic>?;
    //         if(args != null){
    //           return AddEditRecipeScreen(recipe: args['recipe'],);
    //         }
    //         return AddEditRecipeScreen();
    //       },
    //     ),
    //   ],
    // ),
