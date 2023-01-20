import 'package:flutter/material.dart';
import 'package:flutter_todo/domain/data_provider/box_manager.dart';
import 'package:flutter_todo/domain/entity/group.dart';

class GroupFormWidgetModel extends ChangeNotifier {

  // название группы, сюда мы запишем значение полученное с формы:
  var _groupName = '';

  // текст ошибки которая будет выводится если поле пустое:
  String? errorText;

  // сеттер который убирает ошибку если пользователь
  // начал вводить текст, также данный сеттер записывает значение в переменную:
  set groupName(String value) {
    if (errorText != null && value.trim().isNotEmpty) {
      errorText = null;
      notifyListeners();
    }
    _groupName = value;
  }

  // метод сохранения группы в бокс:
  void saveGroup(BuildContext context) async {
    
    // убираем пробелы в названии группы и переносы:
    final groupName = _groupName.trim();

    // срабатывает если в поле ничего не ввели, 
    //записывает значение в переменную с текстовкой ошибки и производит выход из метода:
    if (groupName.isEmpty) {
      errorText = 'Введите название группы';
      notifyListeners();
      return;
    }

    // если же поле не пустое, то производит открытие бокса и подключение адаптера:
    final box = await BoxManager.instance.openGroupBox();

    // создает экземпляр класса с нужным названием группы:
    final group = Group(name: groupName);

    // просто добавляет его в бокс с помощью адаптера:
    await box.add(group);

    // закрывает бокс, но там он необязательно, что закроется:
    await BoxManager.instance.closeBox(box);

    // выходит из экрана формы:
    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
  }
}

// провайдер который внедряет модель и производит перерисовку билдов у виджетов:
class GroupFormWidgetModelProvider extends InheritedNotifier {
  final GroupFormWidgetModel model;

  const GroupFormWidgetModelProvider(
      {super.key, required Widget child, required this.model})
      : super(child: child, notifier: model);

  static GroupFormWidgetModelProvider? watch(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<GroupFormWidgetModelProvider>();
  }

  static GroupFormWidgetModelProvider? read(BuildContext context) {
    final widget = context
        .getElementForInheritedWidgetOfExactType<GroupFormWidgetModelProvider>()
        ?.widget;
    return widget is GroupFormWidgetModelProvider ? widget : null;
  }
}
