
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sayuga/utils/camera_utils.dart';

part 'camera_state.dart';

class CameraCubit extends Cubit<CameraState> {
  final CameraUtils cameraUtils;
  bool rearCameraSelected = true;
  CameraController? controller;
  double? minAvailableZoom;
  double? maxAvailableZoom;
  double? minAvailableExposureOffset;
  double? maxAvailableExposureOffset;
  CameraCubit({required this.cameraUtils}) : super(CameraLoading()) {
    startCamera();
  }

  Future<void> startCamera({int cameraDirection = 0}) async {
    await controller?.dispose();
    emit(CameraLoading());
    CameraController cameraController = await cameraUtils.getCameraController(
        cameraDirection:
            cameraDirection); //need to reset zoomlevel and currentExposureoffset
    controller = cameraController;
    if (cameraDirection == 1) {
      rearCameraSelected = false;
    }
    try {
      await controller!.initialize();

      await Future.wait([
        controller!
            .getMinExposureOffset()
            .then((value) => minAvailableExposureOffset = value),
        controller!
            .getMaxExposureOffset()
            .then((value) => maxAvailableExposureOffset = value),
        controller!.getMaxZoomLevel().then((value) => maxAvailableZoom = value),
        controller!.getMinZoomLevel().then((value) => minAvailableZoom = value),
      ]);
      emit(CameraInitialized(
          cameraController: controller!,
          rearCameraSelected: rearCameraSelected,
          maxAvailableExposureOffset: maxAvailableExposureOffset!,
          maxAvailableZoom: maxAvailableZoom!,
          minAvailableExposureOffset: minAvailableExposureOffset!,
          minAvailableZoom: minAvailableZoom!));
          
      // _currentFlashMode = controller!.value.flashMode;
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
          emit(CameraFailed(error: 'You have denied camera access.'));
          break;
        case 'CameraAccessDeniedWithoutPrompt':
          // iOS only
          emit(CameraFailed(
              error: 'Please go to Settings app to enable camera access.'));

          break;
        case 'CameraAccessRestricted':
          // iOS only
          emit(CameraFailed(error: "Camera access is restricted"));

          break;
        case 'AudioAccessDenied':
          emit(CameraFailed(error: 'You have denied audio access.'));

          break;
        case 'AudioAccessDeniedWithoutPrompt':
          // iOS only
          emit(CameraFailed(
              error: 'Please go to Settings app to enable audio access.'));

          break;
        case 'AudioAccessRestricted':
          // iOS only
          emit(CameraFailed(error: 'Audio access is restricted.'));

          break;
        default:
          emit(CameraFailed(error: e.code.toString()));
          break;
      }
    }
  }

  Future<void> stopCamera() async {
    await controller?.dispose();
    emit(CameraStopped());
  }

  @override
  Future<void> close() async {
    await controller?.dispose();
    return super.close();
  }
}
