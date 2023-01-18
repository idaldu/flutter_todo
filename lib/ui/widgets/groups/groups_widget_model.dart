import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo/domain/data_provider/box_manager.dart';
import 'package:flutter_todo/domain/entity/group.dart';
import 'package:flutter_todo/ui/navigation/main_navigation.dart';
import 'package:flutter_todo/ui/widgets/tasks/tasks_widget.dart';
import 'package:hive_flutter/hive_flutter.dart';

class GroupsWidgetModel extends ChangeNotifier {
  late final Future<Box<Group>> _box;
  ValueListenable<Object>? _listenableBox;
  var _groups = <Group>[];

  List<Group> get groups => _groups.toList();

  GroupsWidgetModel() {
    _setup();
  }

  void showForm(BuildContext context) {
    Navigator.of(context).pushNamed(MainNavigationRoutsNames.groupsForm);
  }

  Future<void> showTask(BuildContext context, groupIndex) async {
    // тут мы знаем что у нас будет точно int так как
    // генерим ключ автоматически, а он всегда int
    final group = (await _box).getAt(groupIndex);
    if (group != null) {
      final configuration = TaskWidgetConfiguration(
        groupKey: group.key,
        title: group.name,
      );

      // специальная функция когда нам не нужно дожидаться
      // завершения Future
      unawaited(
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushNamed(
          MainNavigationRoutsNames.tasks,
          arguments: configuration,
        ),
      );
    }
  }

  Future<void> _readGroupsFromHive() async {
    _groups = (await _box).values.toList();
    notifyListeners();
  }

  Future<void> _setup() async {
    _box = BoxManager.instance.openGroupBox();
    await _readGroupsFromHive();
    _listenableBox = (await _box).listenable();
    _listenableBox?.addListener(_readGroupsFromHive);
  }

  // удаляем бокс с тасками который подвязан к группе,
  // после удаляем саму группу
  Future<void> deleteGroup(int groupIndex) async {
    final box = await _box;
    final groupKey = (await _box).keyAt(groupIndex) as int;
    final taskBoxName = BoxManager.instance.makeTaskBoxName(groupKey);
    await Hive.deleteBoxFromDisk(taskBoxName);
    await box.deleteAt(groupIndex);
  }

  // удаляем подписку и закрываем бокс, после того
  // как мы закончили работу с моделью
  @override
  Future<void> dispose() async {
    _listenableBox?.removeListener(_readGroupsFromHive);
    await BoxManager.instance.closeBox(await _box);
    super.dispose();
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
