import 'package:flutter/material.dart';
import 'package:flutter_todo/domain/data_provider/box_manager.dart';
import 'package:flutter_todo/domain/entity/task.dart';

class TasksFormWidgetModel {
  var taskText = '';
  int groupKey;

  TasksFormWidgetModel({required this.groupKey});

  void saveTasks(BuildContext context) async {
    if (taskText.isEmpty) return;

    final task = Task(text: taskText, isDone: false);
    final box = await BoxManager.instance.openTaskBox(groupKey);
    await box.add(task);
    await BoxManager.instance.closeBox(box);
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
