import 'package:flutter/material.dart';
import 'package:flutter_todo/domain/data_provider/box_manager.dart';
import 'package:flutter_todo/domain/entity/task.dart';

class TasksFormWidgetModel extends ChangeNotifier {

  // название таски, сюда мы запишем значение полученное с формы:
  var _taskText = '';

  // получаем ключ группы, его мы передадим при создании экземпляра модели:
  int groupKey;

  // меняем флаг если текст не пустой:
  bool get isValid => _taskText.trim().isNotEmpty;

  // проверка на изменения в поле, сравниваем старый текст с новым,
  // если оно пустое и опять полное происходит отрисовка виджетов:
  set taskText(String value) {
    final isTaskTextEmpty = _taskText.trim().isEmpty;
    _taskText = value;

    if (value.trim().isEmpty != isTaskTextEmpty) {
      notifyListeners();
    }
  }

  TasksFormWidgetModel({required this.groupKey});

  // метод сохранения такски в бокс:
  void saveTasks(BuildContext context) async {

    // убрал пробелы и переносы в тексте
    final taskText = _taskText.trim();
    
    // создаем экземпляр такси в который передаем значения и флаг:
    final task = Task(text: taskText, isDone: false);

    // открываем бокс и подключаем адаптер:
    final box = await BoxManager.instance.openTaskBox(groupKey);

    // просто добавляем таксу в бокс без ключа:
    await box.add(task);

    // закрываем бокс, но он необязательно закроется:
    await BoxManager.instance.closeBox(box);

    // выходим из формы:
    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
  }
}

// провайдер который внедряет модель и производит перерисовку билдов у виджетов:
class TaskFormWidgetModelProvider extends InheritedNotifier {
  final TasksFormWidgetModel model;

  const TaskFormWidgetModelProvider(
      {super.key, required Widget child, required this.model})
      : super(
          child: child,
          notifier: model,
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
