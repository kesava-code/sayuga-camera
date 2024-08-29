part of 'camera_cubit.dart';

abstract class CameraState {
  const CameraState();
}

class CameraLoading extends CameraState {}

class CameraInitialized extends CameraState {
  final double minAvailableZoom;
  final double maxAvailableZoom;
  final CameraController cameraController;
  final double minAvailableExposureOffset;
  final double maxAvailableExposureOffset;
  final bool rearCameraSelected;

  CameraInitialized(
      {required this.cameraController,
      required this.rearCameraSelected,
      required this.maxAvailableExposureOffset,
      required this.maxAvailableZoom,
      required this.minAvailableExposureOffset,
      required this.minAvailableZoom});
}

class CameraStopped extends CameraState {}

class CameraFailed extends CameraState {
  final String error;
  CameraFailed({required this.error});
}
