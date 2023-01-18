import 'package:flutter/material.dart';
import 'package:flutter_todo/domain/data_provider/box_manager.dart';
import 'package:flutter_todo/domain/entity/task.dart';

class TasksFormWidgetModel extends ChangeNotifier {
  var _taskText = '';
  int groupKey;

  // меняем флаг если текст не пустой
  bool get isValid => _taskText.trim().isNotEmpty;

  // проверка на изменения в поле, сравниваем старый текст с новым
  set taskText(String value) {
    final isTaskTextEmpty = _taskText.trim().isEmpty;
    _taskText = value;

    if (value.trim().isEmpty != isTaskTextEmpty) {
      notifyListeners();
    }
  }

  TasksFormWidgetModel({required this.groupKey});

  void saveTasks(BuildContext context) async {
    // убрал пробелы и переносы в тексте
    final taskText = _taskText.trim();

    final task = Task(text: taskText, isDone: false);
    final box = await BoxManager.instance.openTaskBox(groupKey);
    await box.add(task);
    await BoxManager.instance.closeBox(box);
    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
  }
}

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
