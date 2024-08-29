part of 'refreshcapturedimages_cubit.dart';

abstract class RefreshcapturedimagesState {
  const RefreshcapturedimagesState();
}

class RefreshcapturedimagesLoading extends RefreshcapturedimagesState {}

class RefreshcapturedimagesMP4 extends RefreshcapturedimagesState {
  final String filename;
  RefreshcapturedimagesMP4({required this.filename});
}

class RefreshcapturedimagesJPEG extends RefreshcapturedimagesState {
  final String filename;
  RefreshcapturedimagesJPEG({required this.filename});
}

class RefreshcapturedimagesEmpty extends RefreshcapturedimagesState {}

class RefreshcapturedimagesError extends RefreshcapturedimagesState {
  final String error;
  RefreshcapturedimagesError({required this.error});
}
