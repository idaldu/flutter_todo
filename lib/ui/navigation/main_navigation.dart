import 'package:flutter/material.dart';
import 'package:flutter_todo/ui/widgets/group_form/group_form_widget.dart';
import 'package:flutter_todo/ui/widgets/groups/groups_widget.dart';
import 'package:flutter_todo/ui/widgets/task_form/task_form_widget.dart';
import 'package:flutter_todo/ui/widgets/tasks/tasks_widget.dart';

// тут специально сделан первый экран как `/` для того
// чтобы не отрисовывалась кнопка назад на первом экране
// она бы отрисовывалась из-за initialRoute, так как он
// расформировывает все на пути через слеш, а сам слеш это тоже путь
abstract class MainNavigationRoutsNames {
  static const groups = '/';
  static const groupsForm = '/groupForm';
  static const tasks = '/tasks';
  static const tasksForm = '/tasks/form';
}

// с помощью данного класса мы управляем
// маршрутами с одного места

// вся навигация прописана тут
class MainNavigation {
  // главный роут с которого стартует прила
  final initialRoute = MainNavigationRoutsNames.groups;

  // прописали все роуты, чтобы также менять их в одном месте,
  // обязательно у мапы указывать тип, чтобы компилятор не тратил на
  // это время
  final routes = <String, Widget Function(BuildContext)>{
    MainNavigationRoutsNames.groups: (context) => const GroupsWidget(),
    MainNavigationRoutsNames.groupsForm: (context) => const GroupFormWidget(),
  };

  // данная функция генерит установленный виджет в зависимости
  // от переданного пути, также она может передавать аргументы,
  // что выгодно отличает ее от навигации выше.
  // тут тип object потому как он безопаснее,
  // у него есть свойства только Object, а e dynamic
  // есть все свойства
  Route<Object> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // тут через конструктор мы передаем groupKey
      case MainNavigationRoutsNames.tasks:
        final configuration = settings.arguments as TaskWidgetConfiguration;
        return MaterialPageRoute(
          builder: (context) => TasksWidget(configuration: configuration),
        );
      case MainNavigationRoutsNames.tasksForm:
        final groupKey = settings.arguments as int;
        return MaterialPageRoute(
          builder: (context) => TaskFormWidget(groupKey: groupKey),
        );
      default:
        const widget = Text('Route Error!!!');
        return MaterialPageRoute(
          builder: (context) => widget,
        );
    }
  }
}
