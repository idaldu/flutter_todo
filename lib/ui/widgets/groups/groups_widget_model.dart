import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo/domain/data_provider/box_manager.dart';
import 'package:flutter_todo/domain/entity/group.dart';
import 'package:flutter_todo/ui/navigation/main_navigation.dart';
import 'package:flutter_todo/ui/widgets/tasks/tasks_widget.dart';
import 'package:hive_flutter/hive_flutter.dart';

class GroupsWidgetModel extends ChangeNotifier {
  // создаем переменную в классе для 
  // обращения к боксу с любых методов:
  late final Future<Box<Group>> _box;

  // создаем переменную в классе, 
  // чтобы отменить подписку в методе dispose:
  ValueListenable<Object>? _listenableBox;

  // создаем список с группами в который 
  // мы будем создавать группы и добавлять их:
  var _groups = <Group>[];

  // геттер который предоставляем доступ к списку групп,
  // но не дает возможность перезаписать приватный метод:
  List<Group> get groups => _groups.toList();

  // в констукторе метод будет вызван 
  // как только мы обратимся к данному классу:
  GroupsWidgetModel() {
    _setup();
  }

  // переходим на форму создания группы, тут просто используем 
  // статичные свойства для перехода, без отправки конфигурации:
  void showForm(BuildContext context) {
    Navigator.of(context).pushNamed(MainNavigationRoutsNames.groupsForm);
  }

  // переход в форму тасков с передачей аргумента, с именем и ключем
  // для группы тасков:
  Future<void> showTask(BuildContext context, groupIndex) async {
    final group = (await _box).getAt(groupIndex);
    if (group != null) {

      // создаем экземпляр конфигурации в который мы передаем параметры
      // с группы которыю мы выбрали по индексу
      final configuration = TaskWidgetConfiguration(
        groupKey: group.key,
        title: group.name,
      );

      // специальная функция когда нам не нужно дожидаться
      // завершения Future
      unawaited(
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
