// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:flutter_todo/ui/widgets/task_form/task_form_widget_model.dart';

//* используем StatefulWidget так как он хранит модель логики:
class TaskFormWidget extends StatefulWidget {
  // получили ключ группы который мы передали через навигацию:
  final int groupKey;

  const TaskFormWidget({
    Key? key,
    required this.groupKey,
  }) : super(key: key);

  @override
  TaskFormWidgetState createState() => TaskFormWidgetState();
}

class TaskFormWidgetState extends State<TaskFormWidget> {
  // создаем экземпляр модели:
  late final TasksFormWidgetModel _model;

  @override
  void initState() {
    super.initState();

    // инициализировали модель,
    // передали ключ используя специальный метод у виджета:
    _model = TasksFormWidgetModel(groupKey: widget.groupKey);
  }

  @override
  Widget build(BuildContext context) {
    // используем провайдер, чтобы передать через него модель,
    // данный провайдер обновляет build если в модели произошли
    // изменения:
    return TaskFormWidgetModelProvider(
      model: _model,
      child: const _TextFormWidgetBody(),
    );
  }
}

//* виджет в котором находится Scaffold данного экрана:
class _TextFormWidgetBody extends StatelessWidget {
  const _TextFormWidgetBody();

  @override
  Widget build(BuildContext context) {
    // упрощаем вызов модели в виджете:
    final model = TaskFormWidgetModelProvider.watch(context)?.model;

    // записали кнопку в переменную,
    // мы ее подставим если выполнится условие ниже:
    final actionButton = FloatingActionButton(
      onPressed: () => model?.saveTasks(context),
      child: const Icon(Icons.done),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Новая задача'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: _TaskTextWidget(),
        ),
      ),

      // показываем кнопку только когда вписали текст:
      floatingActionButton: model?.isValid == true ? actionButton : null,
    );
  }
}

//* тело экрана, он получает группы из списка и отрисовывает их:
class _TaskTextWidget extends StatelessWidget {
  const _TaskTextWidget();

  @override
  Widget build(BuildContext context) {
    // упростили работу с моделью:
    final model = TaskFormWidgetModelProvider.read(context)?.model;

    // реализовали поле ввода на весь экран, без рамок:
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        autofocus: true,
        minLines: null,
        maxLines: null,
        expands: true,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Задача',
        ),

        // получаем значение из поля и записываем его в название группы:
        onChanged: (value) => model?.taskText = value,

        // вызываем метод сохранения группы в боксе:
        onEditingComplete: () => model?.saveTasks(context),
      ),
    );
  }
}
