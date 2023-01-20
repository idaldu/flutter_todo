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

  // переход в группу тасков с передачей аргумента, с именем и ключем
  // для группы тасков:
  Future<void> showTask(BuildContext context, groupIndex) async {
    // получаем группу из бокса и записываем ее в переменную:
    final group = (await _box).getAt(groupIndex);

    // если в группе не пусто, создаем экземпляр конфигурации в который мы передаем параметры
    // с группы которыю мы выбрали по индексу
    if (group != null) {
      final configuration = TaskWidgetConfiguration(
        groupKey: group.key,
        title: group.name,
      );

      // специальная функция когда нам не нужно дожидаться
      // завершения Future
      // переходим на экран задач и передаем конфигурацию:
      unawaited(
        Navigator.of(context).pushNamed(
          MainNavigationRoutsNames.tasks,
          arguments: configuration,
        ),
      );
    }
  }

  // читаем группы из бокса и превращаем их в лист,
  // далее этот лист передаем в _groups:
  Future<void> _readGroupsFromHive() async {
    _groups = (await _box).values.toList();

    // данный метод вызывает обновление виджетов у провайдера:
    notifyListeners();
  }

  // первоначальная настройка, вызывается в конструкторе:
  Future<void> _setup() async {

    // открываем бокс и регистрируем адаптер:
    _box = BoxManager.instance.openGroupBox();

    // читаем группы и записываем их в лист _groups:
    await _readGroupsFromHive();

    // подключаем подписку на бокс, если что-то
    // изменилось в боксе то мы вызываем _readGroupsFromHive
    // и снова вызываем функцию _readGroupsFromHive тем самым
    // обновляя список групп:
    _listenableBox = (await _box).listenable();
    _listenableBox?.addListener(_readGroupsFromHive);
  }

  // удаляем бокс с тасками который подвязан к группе,
  // после удаляем саму группу
  Future<void> deleteGroup(int groupIndex) async {
    // ждем и открываем бокс:
    final box = await _box;

    // по индексу достаем ключ бокса и записываем его:
    final groupKey = (await _box).keyAt(groupIndex) as int;

    // по ключу группы получаем имя бокса с тасками:
    final taskBoxName = BoxManager.instance.makeTaskBoxName(groupKey);

    // удаляем бокс с тамсками который привязан к данной группе:
    await Hive.deleteBoxFromDisk(taskBoxName);

    // удаляем группу из бокса с группами:
    await box.deleteAt(groupIndex);
  }

  // удаляем подписку и закрываем бокс, после того
  // как мы закончили работу с моделью
  // данная функция будет вызываться уже в
  // виджете через модель. Чтобы когда виджет
  // закроется вызвалась она и безопасно закрыла бокс:
  @override
  Future<void> dispose() async {
    // закрываем подписку на бокс:
    _listenableBox?.removeListener(_readGroupsFromHive);

    // закрываем бокс спец. методом:
    await BoxManager.instance.closeBox(await _box);
    super.dispose();
  }
}

// провайдер который передает модель в дерево виджетов,
// а также в зависимости от метода обновляем билд у виджета если были изменения:
class GroupsWidgetModelProvider extends InheritedNotifier {
  // в него нужно передать модель в которой прописана вся логика:
  final GroupsWidgetModel model;

  const GroupsWidgetModelProvider(
      {super.key, required Widget child, required this.model})
      : super(
          child: child,

          // далее тут она передается, так как мы будем производить обновление вилжетов
          // а не просто получать какие-либо методы из модели:
          notifier: model,
        );

  // данный метод подписывается на изменения в модели его вызывает notifyListeners()
  // который производит запрос на обновление:
  static GroupsWidgetModelProvider? watch(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<GroupsWidgetModelProvider>();
  }

  // данный метод просто передает методы которые можно дергать в дереве, без подписки: 
  static GroupsWidgetModelProvider? read(BuildContext context) {
    final widget = context
        .getElementForInheritedWidgetOfExactType<GroupsWidgetModelProvider>()
        ?.widget;
    return widget is GroupsWidgetModelProvider ? widget : null;
  }
}
