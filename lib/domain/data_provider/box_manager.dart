import 'package:hive_flutter/hive_flutter.dart';
import '../entity/group.dart';
import '../entity/task.dart';

// данный класс работает через синглтон,
//его нельзя изменить и создать его экземпляр:
class BoxManager {
  final Map<String, int> _boxCounter = <String, int>{};

  // нельзя создать экземпляр данного класса, он доступен глобально
  // по всему приложению, паттерн синглтон:
  static final BoxManager instance = BoxManager._();

  BoxManager._();

  // открываем бокс групп и проверяем/регистрируем адаптер
  // для этой группы, ожидание будет уже в коде далее
  // а тут мы просто возвращаем Future
  Future<Box<Group>> openGroupBox() async {
    return _openBox('group_box', 0, GroupAdapter());
  }

  // открываем бокс со своим ключем, для каждой группы
  // есть свой ключ, мы его передаем в функцию
  Future<Box<Task>> openTaskBox(int groupKey) async {
    return _openBox(makeTaskBoxName(groupKey), 1, TaskAdapter());
  }

  // закрытие бокса + использование метода compact()
  // который удаляет все что хранится в ОЗУ
  // тут происходит сверка сколько раз был открыт бокс и сколько был закрыт,
  // если число сходится то бокс закрывается:
  Future<void> closeBox<T>(Box<T> box) async {
    if (!box.isOpen) {
      _boxCounter.remove(box.name);
      return;
    }

    var count = _boxCounter[box.name] ?? 1;
    count -= 1;
    _boxCounter[box.name] = count;
    if (count > 0) return;

    _boxCounter.remove(box.name);
    await box.compact();
    await box.close();
  }

  // генерирует строку для названия бокса задач, используется в методе выше
  String makeTaskBoxName(int groupKey) => 'tasks_box_$groupKey';

  // проверяем зарег. ли адаптер (нет, тогда регаем)  и открываем бокс.
  // она приватная так как нужна для составления вверхних функций,
  // тут ведется счётчик открытия для проверки можно ли закрывать:
  Future<Box<T>> _openBox<T>(
    String name,
    int typeId,
    TypeAdapter<T> adapter,
  ) async {
    if (Hive.isBoxOpen(name)) {
      final count = _boxCounter[name] ?? 1;
      _boxCounter[name] = count + 1;
      return Hive.box(name);
    }
    _boxCounter[name] = 1;
    if (!Hive.isAdapterRegistered(typeId)) {
      Hive.registerAdapter(adapter);
    }
    return Hive.openBox<T>(name);
  }
}
