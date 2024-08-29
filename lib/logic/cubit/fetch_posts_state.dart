part of 'fetch_posts_cubit.dart';

abstract class FetchPostsState {
  const FetchPostsState();
}

class FetchPostsLoading extends FetchPostsState {}

class FetchPostsLoaded extends FetchPostsState {
  final List<String> posts;
  FetchPostsLoaded({required this.posts});
}

class FetchPostsError extends FetchPostsState {
  final String error;
  FetchPostsError({required this.error});
}
