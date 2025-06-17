import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:recipe_demo_flutter/widget/inkwell_button.dart';

class OutfitColorPicker extends StatefulWidget {
  const OutfitColorPicker({super.key});

  @override
  State<OutfitColorPicker> createState() => _OutfitColorPickerState();
}

class _OutfitColorPickerState extends State<OutfitColorPicker> with SingleTickerProviderStateMixin {
  List<Color> circleColors = [
    Colors.grey.shade300, // Top
    Colors.grey.shade300, // Bottom
    Colors.grey.shade300, // Accessory
  ];

  String suggestion = 'Pick your colors to get outfit ideas!';

  late AnimationController _controller;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _rotation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  void _pickColor(int index) {
    Color currentColor = circleColors[index];

    showDialog(
      context: context,
      builder: (context) {
        Color tempColor = currentColor;

        return AlertDialog(
          title: Text('Pick color for ${_getPartName(index)}'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: (Color color) {
                tempColor = color;
              },
              showLabel: false,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  circleColors[index] = tempColor;
                  _generateSuggestion();
                });
                Navigator.of(context).pop();
              },
              child: const Text('Select'),
            ),
          ],
        );
      },
    );
  }

  void _generateSuggestion() {
    String topColor = _colorName(circleColors[0]);
    String bottomColor = _colorName(circleColors[1]);
    String accessoryColor = _colorName(circleColors[2]);

    setState(() {
      suggestion =
          "Today's look: Try a $topColor top, $bottomColor bottom, and $accessoryColor accessories!";
    });
  }

  void _randomizeOutfit() {
    setState(() {
      circleColors = List.generate(
          3, (_) => Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0));
      _generateSuggestion();
    });
  }

  String _getPartName(int index) {
    switch (index) {
      case 0:
        return "Top";
      case 1:
        return "Bottom";
      case 2:
        return "Accessory";
      default:
        return "";
    }
  }

  String _colorName(Color color) {
    if (color == Colors.grey.shade300) return "neutral";

    // Crude but fun naming
    final hsl = HSLColor.fromColor(color);
    final h = hsl.hue;
    final l = hsl.lightness;

    if (l > 0.8) return "light shade";
    if (l < 0.2) return "dark shade";

    if (h < 30 || h >= 330) return "red tone";
    if (h < 60) return "orange tone";
    if (h < 90) return "yellow tone";
    if (h < 150) return "green tone";
    if (h < 210) return "cyan tone";
    if (h < 270) return "blue tone";
    if (h < 330) return "purple tone";

    return "stylish color";
  }

  Widget _buildCircle(int index) {
    return GestureDetector(
      onTap: () => _pickColor(index),
      child: Container(
        width: 80,
        height: 80,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: circleColors[index],
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black26, width: 2),
        ),
        child: Center(
          child: Text(
            _getPartName(index),
            style: const TextStyle(fontSize: 10, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildOutfitPreview() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 40,
          color: circleColors[0], // Top
        ),
        Container(
          width: 80,
          height: 60,
          color: circleColors[1], // Bottom
        ),
        Container(
          width: 30,
          height: 30,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: circleColors[2], // Accessory
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Outfit',
          style: TextStyle(
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
        padding: EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCircle(0),
              _buildCircle(1),
              _buildCircle(2),
              const SizedBox(height: 20),
              _buildOutfitPreview(),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  suggestion,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 12),
              RotationTransition(
                turns: _rotation,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: circleColors[2], // Accessory color
                  ),
                  onPressed: _randomizeOutfit,
                  child: const Text("Click me!"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
