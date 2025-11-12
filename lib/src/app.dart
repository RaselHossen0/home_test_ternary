import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/tasks/presentation/pages/analytics_page.dart';
import 'features/tasks/presentation/pages/task_detail_page.dart';
import 'features/tasks/presentation/pages/task_edit_page.dart';
import 'features/tasks/presentation/pages/task_list_page.dart';

class AcmeTasksApp extends ConsumerWidget {
  const AcmeTasksApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Acme Tasks',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      routes: {
        TaskListPage.route: (_) => const TaskListPage(),
        TaskEditPage.route: (_) => const TaskEditPage(),
        AnalyticsPage.route: (_) => const AnalyticsPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == TaskDetailPage.route) {
          final id = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => TaskDetailPage(taskId: id),
          );
        }
        return null;
      },
      initialRoute: TaskListPage.route,
    );
  }
}
