import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:flutter_todo/domain/entity/group.dart';
import 'package:flutter_todo/domain/entity/task.dart';

class TasksFormWidgetModel {
  var taskText = '';
  int groupKey;

  TasksFormWidgetModel({required this.groupKey});

  void saveTasks(BuildContext context) async {
    if (taskText.isEmpty) return;

    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TaskAdapter());
    }

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(GroupAdapter());
    }

    final tasksBox = await Hive.openBox<Task>('tasks_box');
    final task = Task(text: taskText, isDone: false);
    await tasksBox.add(task);

    final groupBox = await Hive.openBox<Group>('group_box');
    final group = groupBox.get(groupKey);
    group?.addTask(tasksBox, task);

    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
  }
}

class TaskFormWidgetModelProvider extends InheritedWidget {
  final TasksFormWidgetModel model;

  const TaskFormWidgetModelProvider(
      {super.key, required Widget child, required this.model})
      : super(
          child: child,
        );

  static TaskFormWidgetModelProvider? watch(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<TaskFormWidgetModelProvider>();
  }

  static TaskFormWidgetModelProvider? read(BuildContext context) {
    final widget = context
        .getElementForInheritedWidgetOfExactType<TaskFormWidgetModelProvider>()
        ?.widget;
    return widget is TaskFormWidgetModelProvider ? widget : null;
  }

  @override
  bool updateShouldNotify(covariant InheritedNotifier<Listenable> oldWidget) {
    return false;
  }
}
