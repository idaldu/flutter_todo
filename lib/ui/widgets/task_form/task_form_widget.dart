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

  // старый вариант исполнения
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();

  // тут мы создали экзепляр класса и передали
  // в него ключ группы, при этом мы если вызовется
  // метод didChangeDependencies, модель не будет снова
  // инициализированна
  //   if (_model == null) {
  //     final groupKey = ModalRoute.of(context)!.settings.arguments as int;
  //     _model = TasksFormWidgetModel(groupKey: groupKey);
  //   }
  // }

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
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            TaskFormWidgetModelProvider.read(context)?.model.saveTasks(context),
        child: const Icon(Icons.done),
      ),
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
