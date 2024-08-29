part of 'video_cubit.dart';

abstract class VideoState {
  const VideoState();
}

class VideoInitial extends VideoState {}

class VideoRecording extends VideoState {}

class VideoRecorded extends VideoState {
  
}

class VideoRecordingError extends VideoState {
  final String error;
  VideoRecordingError({required this.error});
}
