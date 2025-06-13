import 'package:hive_flutter/hive_flutter.dart';

part 'note.g.dart';

@HiveType(typeId: 2)
class Note{
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final DateTime createdAt;
  Note({
    required this.id,
    required this.content,
    DateTime? createdAt
  }) : createdAt = createdAt ?? DateTime.now();
}