import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/connectivity_service.dart';
import '../../tasks/data/task_model.dart';
import '../../tasks/data/task_repository.dart';

final repositoryProvider = Provider<TaskRepository>((ref) => TaskRepository());

final connectivityProvider = StreamProvider<bool>((ref) async* {
  await ConnectivityService.instance.init();
  yield* ConnectivityService.instance.isOnlineStream;
});

class TaskFilters {
  TaskFilters(
      {this.status, this.category, this.sortBy = 'date', this.search = ''});
  final String? status;
  final String? category;
  final String sortBy; // date | priority | title
  final String search;

  TaskFilters copyWith(
      {String? status, String? category, String? sortBy, String? search}) {
    return TaskFilters(
      status: status ?? this.status,
      category: category ?? this.category,
      sortBy: sortBy ?? this.sortBy,
      search: search ?? this.search,
    );
  }
}

final filtersProvider = StateProvider<TaskFilters>((ref) => TaskFilters());

final tasksProvider = FutureProvider.autoDispose<List<Task>>((ref) {
  final repo = ref.watch(repositoryProvider);
  final filters = ref.watch(filtersProvider);
  return repo.getTasks(
    status: filters.status,
    category: filters.category,
    sortBy: filters.sortBy,
    search: filters.search,
  );
});

final syncControllerProvider = Provider<SyncController>((ref) {
  final repo = ref.read(repositoryProvider);
  return SyncController(repo);
});

class SyncController {
  SyncController(this._repo);
  final TaskRepository _repo;
  Timer? _timer;

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      _repo.processSyncQueue();
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
