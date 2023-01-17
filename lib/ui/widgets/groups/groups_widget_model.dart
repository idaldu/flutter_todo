import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_todo/domain/entity/group.dart';
import 'package:flutter_todo/domain/entity/task.dart';
import 'package:flutter_todo/ui/navigation/main_navigation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class GroupsWidgetModel extends ChangeNotifier {
  var _groups = <Group>[];

  List<Group> get groups => _groups.toList();

  GroupsWidgetModel() {
    _setup();
  }

  void showForm(BuildContext context) {
    Navigator.of(context).pushNamed(MainNavigationRoutsNames.groupsForm);
  }

  void showTask(BuildContext context, groupIndex) async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(GroupAdapter());
    }
    final box = await Hive.openBox<Group>('group_box');

    // тут мы знаем что у нас будет точно int так как
    // генерим ключ автоматически, а он всегда int
    final groupKey = box.keyAt(groupIndex) as int;

    // специальная функция когда нам не нужно дожидаться
    // завершения Future
    unawaited(
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushNamed(MainNavigationRoutsNames.tasks, arguments: groupKey));
  }

  _readGroupsFromHive(Box<Group> box) {
    _groups = box.values.toList();
    notifyListeners();
  }

  void _setup() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(GroupAdapter());
    }
    final box = await Hive.openBox<Group>('group_box');
    _readGroupsFromHive(box);
    box.listenable().addListener(() => _readGroupsFromHive(box));
  }

  void deleteGroup(int index) async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(GroupAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TaskAdapter());
    }
    final box = await Hive.openBox<Group>('group_box');
    await Hive.openBox<Task>('tasks_box');
    await box.getAt(index)?.tasks?.deleteAllFromHive();
    await box.deleteAt(index);
  }
}

class GroupsWidgetModelProvider extends InheritedNotifier {
  final GroupsWidgetModel model;

  const GroupsWidgetModelProvider(
      {super.key, required Widget child, required this.model})
      : super(
          child: child,
          notifier: model,
        );

  static GroupsWidgetModelProvider? watch(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<GroupsWidgetModelProvider>();
  }

  static GroupsWidgetModelProvider? read(BuildContext context) {
    final widget = context
        .getElementForInheritedWidgetOfExactType<GroupsWidgetModelProvider>()
        ?.widget;
    return widget is GroupsWidgetModelProvider ? widget : null;
  }
}
