import 'package:flutter/material.dart';
import 'package:flutter_todo/widgets/app/my_app.dart'; 
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  // добавляем чтобы функция могла работать в асинхроне
  WidgetsFlutterBinding.ensureInitialized();

  // подключаем Hive
  await Hive.initFlutter();
  const app = MyApp();
  runApp(app);
}
