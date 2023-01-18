import 'package:hive_flutter/hive_flutter.dart';

part 'group.g.dart';

@HiveType(typeId: 0)
class Group extends HiveObject {
  // last used HiveField key 1
  @HiveField(0)
  String name;

  Group({
    required this.name,
  });
}
