import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:recipe_demo_flutter/features/plan/widget/recipe_dropdown.dart';
import 'package:recipe_demo_flutter/features/recipe/model/recipe.dart';
import 'package:recipe_demo_flutter/helper.dart';
import 'package:recipe_demo_flutter/services/database_service.dart';
import 'package:recipe_demo_flutter/widget/inkwell_button.dart';

class MealCalendarScreen extends StatefulWidget {
  const MealCalendarScreen({super.key});
  @override
  _MealCalendarScreenState createState() => _MealCalendarScreenState();
}

class _MealCalendarScreenState extends State<MealCalendarScreen> {
  int weekOffset = 0;
  List<String> get days => getWeekDays(weekOffset: weekOffset);
  // final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<String> meals = ['Breakfast', 'Lunch', 'Dinner'];

  // Map<String, Map<String, String?>> mealPlan = {};
  Map<String, Map<String, Map<String, Recipe?>>> allMealPlans = {};
  String? currentWeekKey;

  @override
  void initState() {
    super.initState();
    loadMealPlans();
    if (allMealPlans.containsKey(weekKey)) {
      currentWeekKey = weekKey;
    }
  }

  String get weekKey {
    if (currentWeekKey != null) return currentWeekKey!;

    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1)).add(Duration(days: weekOffset * 7));
    return "${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}";
  }


  Map<String, Map<String, Recipe?>> get mealPlan {
    return allMealPlans[weekKey] ?? {};
  }

  Future<void> loadMealPlans() async {
    final Map<String, Map<String, Map<String, Recipe?>>> parsed = Helper.loadMealPlans();
    setState(() {
      allMealPlans = parsed;
    });
    _ensureWeekInitialized();
  }


  void _ensureWeekInitialized() {
    final key = currentWeekKey ?? weekKey;

    if (!allMealPlans.containsKey(key)) {
      allMealPlans[key] = {
        for (var day in days) day: {for (var meal in meals) meal: null}
      };
    }
  }

  void _assignMeal(String day, String meal) async {
    Recipe? _selected = (mealPlan[day] != null && mealPlan[day]?[meal] != null) ? mealPlan[day]![meal] : null;

    await showDialog<String>(
      context: context,
      builder: (context) {
        bool isReset = false;

        return StatefulBuilder(
          builder: (context, setState) {
            final selectedId = (mealPlan[day]?[meal] != null && !isReset)
                ? mealPlan[day]![meal]!.id
                : null;

            return AlertDialog(
              title: Text('Assign Recipe'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: RecipeDropdown(
                          selectedRecipeId: selectedId,
                          onChanged: (recipe) {
                            setState(() {
                              _selected = recipe;
                            });
                          },
                        ),
                      ),
                      if (mealPlan[day]?[meal] != null)
                        SizedBox(
                          width: 35,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                mealPlan[day]![meal] = null;
                                _selected = null;
                                isReset = true;
                              });
                            },
                            child: Icon(
                              Icons.close,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (mealPlan[day]?[meal] != null) ...[
                    SizedBox(height: 15),
                    InkwellButton(
                      onPressed: () {
                        context.push('/recipe-list/recipe-detail',
                            extra: {'recipe': mealPlan[day]![meal]});
                        context.pop();
                      },
                      title: 'view detail',
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );

    print('selected: $_selected');

      setState(() {
        currentWeekKey ??= weekKey;
        _ensureWeekInitialized();
        allMealPlans[currentWeekKey]![day]![meal] = _selected;
      });
      await savePlan();
  }


  Widget _buildMealCell(String day, String meal) {
    // print('$day, $meal');
    // print('plan: $mealPlan');
    final recipe = mealPlan[day] != null && mealPlan[day]![meal] != null ? mealPlan[day]![meal]?.title : 'Tap to assign';
    return GestureDetector(
      onTap: () => _assignMeal(day, meal),
      child: Container(
        height: 90,
        width: 120,
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: mealPlan[day] != null && mealPlan[day]![meal] != null ? Colors.teal : Colors.transparent,
          border: Border.all(color: Colors.teal),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '$meal: ${recipe ?? 'Tap to assign'}',
          style: TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildDayColumn(String day) {
    return Container(
      width: 120,
      margin: EdgeInsets.only(right:8),
      child: Column(
        children: [
          Text(
            day,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ...meals.map((meal) => _buildMealCell(day, meal)).toList(),
        ],
      ),
    );
  }

  List<String> getWeekDays({int weekOffset = 0}) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1)).add(Duration(days: weekOffset * 7));
    return List.generate(7, (i) {
      final day = monday.add(Duration(days: i));
      return "${day.month}/${day.day}"; // e.g. 5/15
    });
  }

  Future<void> savePlan() async{
    await DatabaseService.mealPlanBox.put('mealPlans', allMealPlans);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Meal Planner',
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
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[ 
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      final today = DateTime.now();
                      final todayWeekStart = today.subtract(Duration(days: today.weekday - 1));

                      final viewedWeekStart = todayWeekStart.add(Duration(days: weekOffset * 7));

                      final isCurrentWeek = todayWeekStart.year == viewedWeekStart.year &&
                                            todayWeekStart.month == viewedWeekStart.month &&
                                            todayWeekStart.day == viewedWeekStart.day;

                      if (!isCurrentWeek) {
                        setState(() {
                          weekOffset--;
                          currentWeekKey = null;
                          _ensureWeekInitialized();
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Already viewing current week. Not allowed to go back.')),
                        );
                      }
                    }
                  ),
                  Text(
                    'Week of ${days.first} - ${days.last}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: () => setState(() {
                        weekOffset++;
                        currentWeekKey = null;
                        _ensureWeekInitialized();
                      }),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                // mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: days.map((day) => _buildDayColumn(day)).toList(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
