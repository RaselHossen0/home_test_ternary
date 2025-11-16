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
    final baseColor = Colors.teal;
    final lightScheme = ColorScheme.fromSeed(
      seedColor: baseColor,
      brightness: Brightness.light,
    ).copyWith(
      secondary: Colors.indigo,
      tertiary: Colors.orange,
    );
    final darkScheme = ColorScheme.fromSeed(
      seedColor: baseColor,
      brightness: Brightness.dark,
    ).copyWith(
      secondary: Colors.indigoAccent,
      tertiary: Colors.orangeAccent,
    );
    final cardShape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
    return MaterialApp(
      title: 'Acme Tasks',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: lightScheme,
        brightness: Brightness.light,
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: lightScheme.primaryContainer,
          foregroundColor: lightScheme.onPrimaryContainer,
        ),
        cardTheme: CardThemeData(
            elevation: 1,
            shape: cardShape,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
        chipTheme: const ChipThemeData(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          side: BorderSide(color: Colors.transparent),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: lightScheme.primary,
          foregroundColor: lightScheme.onPrimary,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: lightScheme.primary,
            foregroundColor: lightScheme.onPrimary,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          isDense: true,
          border: OutlineInputBorder(),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: darkScheme,
        brightness: Brightness.dark,
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: darkScheme.primaryContainer,
          foregroundColor: darkScheme.onPrimaryContainer,
        ),
        cardTheme: CardThemeData(
            elevation: 0,
            shape: cardShape,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
        chipTheme: const ChipThemeData(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          side: BorderSide(color: Colors.transparent),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: darkScheme.primary,
          foregroundColor: darkScheme.onPrimary,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: darkScheme.primary,
            foregroundColor: darkScheme.onPrimary,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          isDense: true,
          border: OutlineInputBorder(),
        ),
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
