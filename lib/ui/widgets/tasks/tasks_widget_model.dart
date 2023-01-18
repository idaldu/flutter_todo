// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo/ui/widgets/tasks/tasks_widget.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:flutter_todo/domain/data_provider/box_manager.dart';
import 'package:flutter_todo/domain/entity/task.dart';
import 'package:flutter_todo/ui/navigation/main_navigation.dart';

class TasksWidgetModel extends ChangeNotifier {
  final TaskWidgetConfiguration configuration;

  // добаввили сюда для того, чтобы можно было
  // работать с боксам повсюду и мы должны будем
  // его дождаться перед работой с ним
  late final Future<Box<Task>> _box;

  ValueListenable<Object>? _listenableBox;

  var _tasks = <Task>[];
  List<Task> get tasks => _tasks.toList();

  TasksWidgetModel({
    required this.configuration,
  }) {
    _setup();
  }

  Future<void> _readTasksFromHive() async {
    _tasks = (await _box).values.toList();
    notifyListeners();
  }

  Future<void> _setup() async {
    _box = BoxManager.instance.openTaskBox(configuration.groupKey);
    await _readTasksFromHive();
    _listenableBox = (await _box).listenable();
    _listenableBox?.addListener(_readTasksFromHive);
  }

  void showForm(BuildContext context) {
    Navigator.of(context).pushNamed(MainNavigationRoutsNames.tasksForm,
        arguments: configuration.groupKey);
  }

  Future<void> deleteTasks(int taskIndex) async {
    await (await _box).deleteAt(taskIndex);
  }

  // меняем флаг у такси на противоположный:
  Future<void> doneToggle(int taskIndex) async {
    final task = (await _box).getAt(taskIndex);
    task?.isDone = !task.isDone;
    task?.save();
  }

  // удаляем бокс с тасками который подвязан к группе,
  // после удаляем саму группу
  @override
  Future<void> dispose() async {
    _listenableBox?.removeListener(_readTasksFromHive);
    await BoxManager.instance.closeBox(await _box);
    super.dispose();
  }
}

class TasksWidgetModelProvider extends InheritedNotifier {
  final TasksWidgetModel model;

  const TasksWidgetModelProvider(
      {super.key, required Widget child, required this.model})
      : super(
          child: child,
          notifier: model,
        );

  static TasksWidgetModelProvider? watch(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<TasksWidgetModelProvider>();
  }

  static TasksWidgetModelProvider? read(BuildContext context) {
    final widget = context
        .getElementForInheritedWidgetOfExactType<TasksWidgetModelProvider>()
        ?.widget;
    return widget is TasksWidgetModelProvider ? widget : null;
  }
}
