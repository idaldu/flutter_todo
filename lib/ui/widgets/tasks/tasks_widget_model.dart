// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_todo/domain/entity/group.dart';
import 'package:flutter_todo/domain/entity/task.dart';
import 'package:flutter_todo/ui/navigation/main_navigation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TasksWidgetModel extends ChangeNotifier {
  int groupKey;

  // добаввили сюда для того, чтобы можно было
  // работать с боксам повсюду и мы должны будем
  // его дождаться перед работой с ним
  late final Future<Box<Group>> _groupBox;

  // сделано чтобы снаружи его нельзя было изменить,
  // а только получить, снаружи мы увидим только этот геттер
  Group? _group;
  Group? get group => _group;
  var _tasks = <Task>[];

  List<Task> get tasks => _tasks.toList();

  TasksWidgetModel({required this.groupKey}) {
    _setup();
  }

  void _loadGroup() async {
    final box = await _groupBox;
    _group = box.get(groupKey);
    notifyListeners();
  }

  _readTasks() {
    _tasks = _group?.tasks ?? <Task>[];
    notifyListeners();
  }

  void _setup() {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(GroupAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TaskAdapter());
    }

    _groupBox = Hive.openBox<Group>('group_box');
    _loadGroup();
    _setupListenTask();
    Hive.openBox<Task>('tasks_box');
  }

  void _setupListenTask() async {
    final box = await _groupBox;
    _readTasks();

    // слушаем изменения которые произошли с группой по
    // определенному ключу
    box.listenable(keys: [groupKey]).addListener(_readTasks);
  }

  void showForm(BuildContext context) {
    Navigator.of(context)
        .pushNamed(MainNavigationRoutsNames.tasksForm, arguments: groupKey);
  }

  void deleteTasks(int groupIndex) async {
    // также для удаления нужно сохранять в боксе это удаление
    await group?.tasks?.deleteFromHive(groupIndex);
    group?.save();
  }

  void doneToggle(int groupIndex) async {
    final task = group?.tasks?[groupIndex];
    final currentState = task?.isDone ?? false;
    task?.isDone = !currentState;
    await task?.save();
    notifyListeners();
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
