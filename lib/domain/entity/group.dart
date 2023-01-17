// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_todo/domain/entity/task.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'group.g.dart';

@HiveType(typeId: 0)
class Group extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  HiveList<Task>? tasks;

  Group({
    required this.name,
  });

  // тут немного непонятно как работает,
  // добавление тасков в лист по идее
  void addTask(Box<Task> box, Task task) {
    tasks ??= HiveList(box);
    tasks?.add(task);

    // нужно обязательно сохранить добавление, чтобы
    // добавилось в лист
    save();
  }
}
