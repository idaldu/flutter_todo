// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:flutter_todo/ui/widgets/task_form/task_form_widget_model.dart';

class TaskFormWidget extends StatefulWidget {
  final int groupKey;
  const TaskFormWidget({
    Key? key,
    required this.groupKey,
  }) : super(key: key);

  @override
  TaskFormWidgetState createState() => TaskFormWidgetState();
}

class TaskFormWidgetState extends State<TaskFormWidget> {
  late final TasksFormWidgetModel _model;

  @override
  void initState() {
    super.initState();

    // инициализировали модель, передали ключ
    _model = TasksFormWidgetModel(groupKey: widget.groupKey);
  }

  @override
  Widget build(BuildContext context) {
    return TaskFormWidgetModelProvider(
      model: _model,
      child: const _TextFormWidgetBody(),
    );
  }
}

class _TextFormWidgetBody extends StatelessWidget {
  const _TextFormWidgetBody();

  @override
  Widget build(BuildContext context) {
    final model = TaskFormWidgetModelProvider.watch(context)?.model;

    // записали кнопку в переменную:
    final actionButton = FloatingActionButton(
      onPressed: () => model?..saveTasks(context),
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

class _TaskTextWidget extends StatelessWidget {
  const _TaskTextWidget();

  @override
  Widget build(BuildContext context) {
    final model = TaskFormWidgetModelProvider.read(context)?.model;

    // реализовали поле ввода на весь экран, без рамок.
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
        onChanged: (value) => model?.taskText = value,
        onEditingComplete: () => model?.saveTasks(context),
      ),
    );
  }
}
