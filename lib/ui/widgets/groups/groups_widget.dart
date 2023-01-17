// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_todo/ui/widgets/groups/groups_widget_model.dart';

class GroupsWidget extends StatefulWidget {
  const GroupsWidget({Key? key}) : super(key: key);

  @override
  State<GroupsWidget> createState() => _GroupsWidgetState();
}

class _GroupsWidgetState extends State<GroupsWidget> {
  final _model = GroupsWidgetModel();

  @override
  Widget build(BuildContext context) {
    return GroupsWidgetModelProvider(
      model: _model,
      child: const GroupWidgetBody(),
    );
  }
}

class GroupWidgetBody extends StatelessWidget {
  const GroupWidgetBody({super.key});

  @override
  Widget build(BuildContext context) {
    final model = GroupsWidgetModelProvider.read(context)?.model;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Группы'),
      ),
      body: const _GroupListWidget(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => model?.showForm(context),
      ),
    );
  }
}

class _GroupListWidget extends StatelessWidget {
  const _GroupListWidget();

  @override
  Widget build(BuildContext context) {
    final groupsCount =
        GroupsWidgetModelProvider.watch(context)?.model.groups.length ?? 0;
    return ListView.separated(
      itemCount: groupsCount,
      separatorBuilder: (BuildContext context, int index) {
        return const Divider(height: 1);
      },
      itemBuilder: (BuildContext context, int index) {
        return _GroupListRowWidget(indexInList: index);
      },
    );
  }
}

class _GroupListRowWidget extends StatelessWidget {
  final int indexInList;

  const _GroupListRowWidget({
    Key? key,
    required this.indexInList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = GroupsWidgetModelProvider.read(context)!.model;
    final group = model.groups[indexInList];
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => model.deleteGroup(indexInList),
            backgroundColor: const Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          )
        ],
      ),
      child: ListTile(
        title: Text(group.name),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => model.showTask(context, indexInList),
      ),
    );
  }
}
