import 'package:flutter/material.dart';
import 'package:flutter_todo/ui/navigation/main_navigation.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final mainNavigation = MainNavigation();

    return MaterialApp(
      title: 'Flutter ToDo',
      theme: ThemeData(primarySwatch: Colors.blue),
      routes: mainNavigation.routes,
      initialRoute: mainNavigation.initialRoute,
      onGenerateRoute: mainNavigation.onGenerateRoute,
    );
  }
}
