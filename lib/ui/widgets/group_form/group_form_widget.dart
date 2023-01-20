import 'package:flutter/material.dart';
import 'package:flutter_todo/ui/widgets/group_form/group_form_widget_model.dart';

//* используем StatefulWidget так как он хранит модель логики:
class GroupFormWidget extends StatefulWidget {
  const GroupFormWidget({Key? key}) : super(key: key);

  @override
  State<GroupFormWidget> createState() => _GroupFormWidgetState();
}

class _GroupFormWidgetState extends State<GroupFormWidget> {
  
  // создаем экземпляр модели:
  final _model = GroupFormWidgetModel();

  @override
  Widget build(BuildContext context) {
    // используем провайдер, чтобы передать через него модель,
    // данный провайдер обновляет build если в модели произошли
    // изменения:
    return GroupFormWidgetModelProvider(
      model: _model,
      child: const _GroupFormWidgetBody(),
    );
  }
}

//* виджет в котором находится Scaffold данного экрана:
class _GroupFormWidgetBody extends StatelessWidget {
  const _GroupFormWidgetBody();

  @override
  Widget build(BuildContext context) {

    // упрощаем вызов модели в виджете:
    final model = GroupFormWidgetModelProvider.read(context)?.model;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Новая группа'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: _GroupNameWidget(),
        ),
      ),
      // кнопка добавления группы, она вызывает нужный метод в модели:
      floatingActionButton: FloatingActionButton(
        onPressed: () => model?.saveGroup(context),
        child: const Icon(Icons.done),
      ),
    );
  }
}

//* тело экрана, он получает группы из списка и отрисовывает их:
class _GroupNameWidget extends StatelessWidget {
  const _GroupNameWidget();

  @override
  Widget build(BuildContext context) {
    final model = GroupFormWidgetModelProvider.watch(context)?.model;
    return TextField(
      autofocus: true,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: 'Имя группы',
        errorText: model?.errorText,
      ),

      // получаем значение из поля и записываем его в название группы:
      onChanged: (value) => model?.groupName = value,

      // вызываем метод сохранения группы в боксе:
      onEditingComplete: () => model?.saveGroup(context),
    );
  }
}
