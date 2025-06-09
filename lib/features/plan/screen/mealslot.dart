import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:recipe_demo_flutter/services/database_service.dart';

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

  Map<String, Map<String, String?>> mealPlan = {};

  @override
  void initState() {
    super.initState();
    loadMealPlans();
    // for (var day in days) {
    //   mealPlan[day] = {for (var meal in meals) meal: null};
    // }
  }

  Future<void> loadMealPlans() async {
    final raw = DatabaseService.mealPlanBox.get('mealPlans');

    if (raw is Map) {
      print('hi');
      try {
        final parsed = Map<String, Map<String, String?>>.from(
          raw.map((day, meals) => MapEntry(
            day.toString(),
            Map<String, String?>.from((meals as Map).map(
              (meal, recipe) => MapEntry(meal.toString(), recipe as String?),
            )),
          )),
        );

        setState(() {
          mealPlan = parsed;
        });
        print('done convert');
      } catch (e) {
        print("Error parsing stored meal plan: $e");
      }
    } else {
      print('Unexpected data format: ${raw.runtimeType}');
    }
  }



  void _assignMeal(String day, String meal) async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Assign Recipe'),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(hintText: 'Enter recipe name'),
          onSubmitted: GoRouter.of(context).pop
        ),
      ),
    );

    if (result != null && result.trim().isNotEmpty) {
      setState(() {
        mealPlan[day]![meal] = result.trim();
      });
      await savePlan();
    }
  }

  Widget _buildMealCell(String day, String meal) {
    print('plan: $mealPlan');
    final recipe = mealPlan[day] != null ? mealPlan[day]![meal] : 'Tap to assign';
    return GestureDetector(
      onTap: () => _assignMeal(day, meal),
      child: Container(
        height: 90,
        width: 120,
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
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
    // print(mealPlan);

    await DatabaseService.mealPlanBox.put('mealPlans', mealPlan);
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
                    onPressed: () => setState(() => weekOffset--),
                  ),
                  Text(
                    'Week of ${days.first} - ${days.last}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: () => setState(() => weekOffset++),
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
