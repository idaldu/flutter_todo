// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:flutter_todo/ui/widgets/tasks/tasks_widget_model.dart';

class TaskWidgetConfiguration {
  final int groupKey;
  final String title;

  TaskWidgetConfiguration({
    required this.groupKey,
    required this.title,
  });
}

class TasksWidget extends StatefulWidget {
  final TaskWidgetConfiguration configuration;
  const TasksWidget({
    Key? key,
    required this.configuration,
  }) : super(key: key);

  @override
  TasksWidgetState createState() => TasksWidgetState();
}

class TasksWidgetState extends State<TasksWidget> {
  // создали свойство с типом нашего класса модели,
  // и перенесли его инициализацию.
  late final TasksWidgetModel _model;

  @override
  void initState() {
    super.initState();
    // выполнили инициализацию модели и передали конфигурацию:
    _model = TasksWidgetModel(configuration: widget.configuration);
  }

  @override
  Widget build(BuildContext context) {
    return TasksWidgetModelProvider(
        // тут по идее нужно обработать если нет модели, но это потом
        model: _model,
        child: const TasksWidgetBody());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }
}

class TasksWidgetBody extends StatelessWidget {
  const TasksWidgetBody({super.key});

  @override
  Widget build(BuildContext context) {
    final model = TasksWidgetModelProvider.watch(context)?.model;
    final title = model?.configuration.title ?? 'Задачи';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: const _TasksListWidget(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => model?.showForm(context),
      ),
    );
  }
}

class _TasksListWidget extends StatelessWidget {
  const _TasksListWidget();

  @override
  Widget build(BuildContext context) {
    final groupsCount =
        TasksWidgetModelProvider.watch(context)?.model.tasks.length ?? 0;
    return ListView.separated(
      itemCount: groupsCount,
      separatorBuilder: (BuildContext context, int index) {
        return const Divider(height: 1);
      },
      itemBuilder: (BuildContext context, int index) {
        return _TasksListRowWidget(indexInList: index);
      },
    );
  }
}

class _TasksListRowWidget extends StatelessWidget {
  final int indexInList;

  const _TasksListRowWidget({
    Key? key,
    required this.indexInList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = TasksWidgetModelProvider.read(context)!.model;
    final task = model.tasks[indexInList];

    final icon = task.isDone
        ? Icons.check_box_rounded
        : Icons.check_box_outline_blank_outlined;

    final style = task.isDone
        ? const TextStyle(decoration: TextDecoration.lineThrough)
        : null;

    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => model.deleteTasks(indexInList),
            backgroundColor: const Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          )
        ],
      ),
      child: ListTile(
        title: Text(
          task.text,
          style: style,
        ),
        trailing: Icon(icon),
        onTap: () => model.doneToggle(indexInList),
      ),
    );
  }
}
