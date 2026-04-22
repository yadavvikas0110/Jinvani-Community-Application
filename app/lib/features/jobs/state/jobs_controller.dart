import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/jobs_repository.dart';
import '../models/job.dart';

class JobsState {
  final List<Job> jobs;
  final bool loading;
  final String? error;
  final String selectedCategory;
  final String searchQuery;

  const JobsState({
    this.jobs = const [],
    this.loading = false,
    this.error,
    this.selectedCategory = 'All',
    this.searchQuery = '',
  });

  JobsState copyWith({
    List<Job>? jobs,
    bool? loading,
    String? error,
    String? selectedCategory,
    String? searchQuery,
  }) =>
      JobsState(
        jobs: jobs ?? this.jobs,
        loading: loading ?? this.loading,
        error: error,
        selectedCategory: selectedCategory ?? this.selectedCategory,
        searchQuery: searchQuery ?? this.searchQuery,
      );
}

class JobsController extends Notifier<JobsState> {
  @override
  JobsState build() {
    Future.microtask(() => loadJobs());
    return const JobsState(loading: true);
  }

  Future<void> loadJobs() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final repo = ref.read(jobsRepositoryProvider);
      final jobs = await repo.fetchJobs(
        category: state.selectedCategory == 'All' ? null : state.selectedCategory,
        query: state.searchQuery.isEmpty ? null : state.searchQuery,
      );
      state = state.copyWith(jobs: jobs, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category);
    loadJobs();
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
    loadJobs();
  }

  Future<void> toggleSave(String jobId) async {
    final repo = ref.read(jobsRepositoryProvider);
    await repo.toggleSave(jobId);
    final updated = state.jobs.map((j) {
      if (j.id == jobId) return j.copyWith(isSaved: !j.isSaved);
      return j;
    }).toList();
    state = state.copyWith(jobs: updated);
  }

  Future<bool> applyToJob(String jobId) async {
    final repo = ref.read(jobsRepositoryProvider);
    final success = await repo.applyToJob(jobId);
    if (success) {
      final updated = state.jobs.map((j) {
        if (j.id == jobId) return j.copyWith(isApplied: true);
        return j;
      }).toList();
      state = state.copyWith(jobs: updated);
    }
    return success;
  }
}

final jobsControllerProvider = NotifierProvider<JobsController, JobsState>(
  JobsController.new,
);

final jobDetailProvider = FutureProvider.family<Job, String>((ref, id) async {
  return ref.read(jobsRepositoryProvider).fetchJobById(id);
});

final appliedJobsProvider = FutureProvider<List<JobApplication>>((ref) async {
  return ref.read(jobsRepositoryProvider).fetchApplications();
});

final savedJobsProvider = FutureProvider<List<Job>>((ref) async {
  return ref.read(jobsRepositoryProvider).fetchSavedJobs();
});

const jobCategories = ['All', 'Accountant', 'Software Developer', 'Project Manager', 'Designer'];
