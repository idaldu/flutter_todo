import 'package:hive_flutter/hive_flutter.dart';

part 'task.g.dart';

@HiveType(typeId: 1)
class Task extends HiveObject {
  @HiveField(0)
  String text;

  @HiveField(1)
  bool isDone;

  Task({
    required this.text,
    required this.isDone,
  });
}
