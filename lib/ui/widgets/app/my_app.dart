import 'package:flutter/material.dart';
import 'package:flutter_todo/ui/navigation/main_navigation.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    // создали экземпляр навигации в которой прописана
    // логика роутов, а также передача конфигурации
    final mainNavigation = MainNavigation();

    return MaterialApp(
      title: 'Flutter ToDo',
      theme: ThemeData(primarySwatch: Colors.blue),

      // основные роуты в которых не передается конфигурация:
      routes: mainNavigation.routes,

      // стартовый экран, роут который откроется вначале:
      initialRoute: mainNavigation.initialRoute,

      // генерация роутов с передачей конфигурации, если мы вызываем роут
      // которого нет в routes, то вызывается данный метод.
      onGenerateRoute: mainNavigation.onGenerateRoute,
    );
  }
}
