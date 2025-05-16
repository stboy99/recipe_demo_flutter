import 'package:flutter/material.dart';

class GlobalStructure extends StatefulWidget {
  final String title;
  final Widget body;
  final Widget? action;

  const GlobalStructure({
    super.key,
    required this.title,
    required this.body,
    this.action
  });

  @override
  State<GlobalStructure> createState() => _GlobalStructureState();
}

class _GlobalStructureState extends State<GlobalStructure> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
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
        actions: widget.action != null ? [widget.action!] : [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: widget.body,
      ),
    );
  }
}
