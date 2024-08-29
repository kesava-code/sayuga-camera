part of 'image_cubit.dart';

abstract class ImageState {
  const ImageState();
}

class ImageInitial extends ImageState {}

class ImageSaved extends ImageState {
  final String imagepath;
  ImageSaved({required this.imagepath});
}

class ImageSavingError extends ImageState {
  final String error;
  ImageSavingError({required this.error});
}


class VideoSaved extends ImageState {
  final String videoPath;
  VideoSaved({required this.videoPath});
}

class VideoSavingError extends ImageState {
  final String error;
  VideoSavingError({required this.error});
}
