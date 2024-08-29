part of 'directories_cubit.dart';

abstract class DirectoriesState {
  const DirectoriesState();
}

class DirectoriesInitial extends DirectoriesState {}

class DirectoriesLoaded extends DirectoriesState {
  final String documentsDirectory;
  final String temporaryDirectory;
  DirectoriesLoaded(
      {required this.temporaryDirectory, required this.documentsDirectory});
}

class DirectoriesError extends DirectoriesState {
  final String error;
  DirectoriesError({required this.error});
}
