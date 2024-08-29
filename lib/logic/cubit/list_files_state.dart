part of 'list_files_cubit.dart';

abstract class ListFilesState{
  const ListFilesState();
}

class ListFilesInitial extends ListFilesState {}

class ListFilesLoaded extends ListFilesState {
  final List<String> files;
  const ListFilesLoaded({required this.files});
}

class ListFilesError extends ListFilesState {
  final String error;
  const ListFilesError({required this.error});
}
