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

  // принимает конфигурацию с помощью которой создает таски:
  final TaskWidgetConfiguration configuration;

  // добаввили сюда для того, чтобы можно было
  // работать с боксам повсюду и мы должны будем
  // его дождаться перед работой с ним
  late final Future<Box<Task>> _box;

  // создаем переменную в классе,
  // чтобы отменить подписку в методе dispose:
  ValueListenable<Object>? _listenableBox;

  // создаем список с задачами  в который
  // мы будем создавать задачи  и добавлять их:
  var _tasks = <Task>[];

  // геттер который предоставляем доступ к списку задач,
  // но не дает возможность перезаписать приватный метод:
  List<Task> get tasks => _tasks.toList();

  // в констукторе метод будет вызван
  // как только мы обратимся к данному классу:
  TasksWidgetModel({
    required this.configuration,
  }) {
    _setup();
  }

  // читаем задачи из бокса и превращаем их в лист,
  // далее этот лист передаем в _tasks:
  Future<void> _readTasksFromHive() async {
    _tasks = (await _box).values.toList();
    notifyListeners();
  }

  // первоначальная настройка, вызывается в конструкторе:
  Future<void> _setup() async {

    // открываем бокс и регистрируем адаптер:
    _box = BoxManager.instance.openTaskBox(configuration.groupKey);

    // читаем группы и записываем их в лист _tasks:
    await _readTasksFromHive();

    // подключаем подписку на бокс, если что-то
    // изменилось в боксе то мы вызываем _readTasksFromHive  тем самым
    // обновляя список задач:
    _listenableBox = (await _box).listenable();
    _listenableBox?.addListener(_readTasksFromHive);
  }

  // переход в форму тасков с передачей аргумента в 
  // виде ключа группы для создания задачи именно в нужном боксе:
  void showForm(BuildContext context) {
    Navigator.of(context).pushNamed(MainNavigationRoutsNames.tasksForm,
        arguments: configuration.groupKey);
  }

  // удаляем таску по индексу который нам передал ViewBuilder:
  Future<void> deleteTasks(int taskIndex) async {
    await (await _box).deleteAt(taskIndex);
  }

  // меняем флаг у такси на противоположный:
  Future<void> doneToggle(int taskIndex) async {
    final task = (await _box).getAt(taskIndex);
    task?.isDone = !task.isDone;

    // обязательно сохраняем таску которую мы изменили:
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
