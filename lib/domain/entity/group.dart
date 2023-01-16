// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:hive_flutter/hive_flutter.dart';

part 'group.g.dart';

@HiveType(typeId: 0)
class Group {

  @HiveField(0)
  String name;

  Group({
    required this.name,
  });
}
