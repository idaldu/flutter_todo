import 'package:flutter/material.dart';
import 'package:flutter_todo/widgets/group_form/group_form_widget.dart';
import 'package:flutter_todo/widgets/groups/groups_widget.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/groups': (context) => const GroupsWidget(),
        '/groups/form': (context) => const GroupFormWidget()
      },
      initialRoute: '/groups',
    );
  }
}
