import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_todo/ui/widgets/groups/groups_widget_model.dart';

//* используем StatefulWidget так как он хранит модель логики:
class GroupsWidget extends StatefulWidget {
  const GroupsWidget({Key? key}) : super(key: key);

  @override
  State<GroupsWidget> createState() => _GroupsWidgetState();
}

class _GroupsWidgetState extends State<GroupsWidget> {
  // создаем экземпляр модели:
  final _model = GroupsWidgetModel();

  @override
  Widget build(BuildContext context) {
    // используем провайдер, чтобы передать через него модель,
    // данный провайдер обновляет build если в модели произошли
    // изменения:
    return GroupsWidgetModelProvider(
      model: _model,
      child: const GroupWidgetBody(),
    );
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
class GroupWidgetBody extends StatelessWidget {
  const GroupWidgetBody({super.key});

  @override
  Widget build(BuildContext context) {
    // упрощаем вызов модели в виджете:
    final model = GroupsWidgetModelProvider.read(context)?.model;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Группы'),
      ),
      body: const _GroupListWidget(),

      // кнопка добавления группы, она вызывает нужный метод в модели:
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => model?.showForm(context),
      ),
    );
  }
}

//* тело экрана, он получает группы из списка и отрисовывает их:
class _GroupListWidget extends StatelessWidget {
  const _GroupListWidget();

  @override
  Widget build(BuildContext context) {
    // получаем длину списка групп, тут нужно вызывать метод watch так как
    // мы следим за изменениями, если список пустой то длина 0:
    final groupsCount =
        GroupsWidgetModelProvider.watch(context)?.model.groups.length ?? 0;

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
        return _GroupListRowWidget(indexInList: index);
      },
    );
  }
}

//* виджет строки группы в которую передается индекс:
class _GroupListRowWidget extends StatelessWidget {
  // в свойствах принимаем индекс по которому
  // вытащим из списка нужную группу:
  final int indexInList;

  const _GroupListRowWidget({
    Key? key,
    required this.indexInList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // получаем модель из провайдера записываем в
    // переменную для упрощения записи в дальнейшем:
    final model = GroupsWidgetModelProvider.read(context)!.model;

    // получаем данные группы
    // из списка по переданному индексу:
    final group = model.groups[indexInList];

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
            onPressed: (context) => model.deleteGroup(indexInList),

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
        // получаем имя группы:
        title: Text(group.name),
        trailing: const Icon(Icons.chevron_right),

        // действие при нажатии, также используем модель для передачи метода:
        onTap: () => model.showTask(context, indexInList),
      ),
    );
  }
}
