// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:flutter_todo/ui/widgets/tasks/tasks_widget_model.dart';

//* конфигурация которая будет передаваться через навигацию
//* для открытия опеределенных боксов с задачами:
class TaskWidgetConfiguration {
  // ключ группы, он будет в названии бокса с таксками
  // которые привязанны к данной группе:
  final int groupKey;

  // название группы, оно будет отображаться вверху в аппбаре:
  final String title;

  TaskWidgetConfiguration({
    required this.groupKey,
    required this.title,
  });
}

//* используем StatefulWidget так как он хранит модель логики:
class TasksWidget extends StatefulWidget {
  // данный виджет принимает конфигурацию, ее класс создавался
  // вверху, и данная конфигурация отправляется через навигацию:
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

    // выполнили инициализацию модели и передали конфигурацию,
    // сделали это в инит стейте непонятно почему, но видимо нужно:
    _model = TasksWidgetModel(configuration: widget.configuration);
  }

  @override
  Widget build(BuildContext context) {
    // используем провайдер, чтобы передать через него модель,
    // данный провайдер обновляет build если в модели произошли
    // изменения:
    return TasksWidgetModelProvider(
        model: _model, child: const TasksWidgetBody());
  }

  // вызываем метод dispose у модели, т.к в нем находится метод закрытия бокса,
  // это очень безопасно так как мы закрываем бокс когда виджет прекратил
  // свое существование:
  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }
}

//* виджет в котором находится Scaffold данного экрана:
class TasksWidgetBody extends StatelessWidget {
  const TasksWidgetBody({super.key});

  @override
  Widget build(BuildContext context) {
    // упрощаем вызов модели в виджете:
    final model = TasksWidgetModelProvider.watch(context)?.model;

    // получаем название группы и если оно пустое,
    // подстаавляем значение по умолчанию:
    final title = model?.configuration.title ?? 'Задачи';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: const _TasksListWidget(),

      // кнопка добавления задачи, вызывает нужный метод в модели:
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => model?.showForm(context),
      ),
    );
  }
}

//* тело экрана, он получает группы из списка и отрисовывает их:
class _TasksListWidget extends StatelessWidget {
  const _TasksListWidget();

  @override
  Widget build(BuildContext context) {

    // получаем длину списка задач, тут нужно вызывать метод watch так как
    // мы следим за изменениями, если список пустой то длина 0:
    final groupsCount =
        TasksWidgetModelProvider.watch(context)?.model.tasks.length ?? 0;
    
    // виджет который отрисовывает группы,
    // а также между ними ставит разделитель:
    return ListView.separated(
      // передаем количество групп которое мы выводим:
      itemCount: groupsCount,

      // устанавлием разделитель который будет между группами:
      separatorBuilder: (BuildContext context, int index) {
        return const Divider(height: 1);
      },

      // установливаем саму группу, выбираем нужную через индекс,
      // этот индекс генерит сам ListView.separated:
      itemBuilder: (BuildContext context, int index) {
        return _TasksListRowWidget(indexInList: index);
      },
    );
  }
}

//* виджет строки группы в которую передается индекс:
class _TasksListRowWidget extends StatelessWidget {

  // в свойствах принимаем индекс по которому
  // вытащим из списка нужную группу:
  final int indexInList;

  const _TasksListRowWidget({
    Key? key,
    required this.indexInList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    // получаем модель из провайдера записываем в
    // переменную для упрощения записи в дальнейшем:
    final model = TasksWidgetModelProvider.read(context)!.model;

    // получаем данные группы
    // из списка по переданному индексу:
    final task = model.tasks[indexInList];

    // выбираем нужную иконку в зависимости от статуса задачи,
    // который мы получили из модели:
    final icon = task.isDone
        ? Icons.check_box_rounded
        : Icons.check_box_outline_blank_outlined;

    // зачеркиваем текст в зависимости от статуса задачи:
    final style = task.isDone
        ? const TextStyle(decoration: TextDecoration.lineThrough)
        : null;

    // виджет который добавляем
    // боковые свайпы для другого виджета:
    return Slidable(

      // данное свойство показываем свайпы вконце,
      //также можно установить вначале:
      endActionPane: ActionPane(

        // вид анимации с которой будут появляться пункты меню:
        motion: const ScrollMotion(),

        // список в котором находятся пункты меню, далее их параметры:
        children: [
          SlidableAction(

            // действие при нажатии на пункт,
            // тут мы через модель вызываем нужный метод:
            onPressed: (context) => model.deleteTasks(indexInList),
            backgroundColor: const Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          )
        ],
      ),

      // сам виджет строки, использовали уже
      // предустановленный с определенными свойствами:
      child: ListTile(

        // получаем имя таски:
        title: Text(
          task.text,
          style: style,
        ),
        trailing: Icon(icon),

        // действие при нажатии, также используем модель для передачи метода:
        onTap: () => model.doneToggle(indexInList),
      ),
    );
  }
}
