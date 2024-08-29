import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:sayuga/logic/cubit/camera_cubit.dart';

part 'flash_mode_state.dart';

class FlashModeCubit extends Cubit<FlashModeState> {
  final CameraCubit cameraCubit;
  FlashModeCubit({required this.cameraCubit}) : super(FlashModeAuto());

  void changeMode() async {
    CameraState stateofCamera = cameraCubit.state;
    if (stateofCamera is CameraInitialized) {
      if (state is FlashModeAuto) {
        await stateofCamera.cameraController.setFlashMode(FlashMode.torch);
        emit(FlashModeTorch());
      } else if (state is FlashModeTorch) {
        await stateofCamera.cameraController.setFlashMode(FlashMode.off);
        emit(FlashModeOff());
      } else if (state is FlashModeOff) {
        await stateofCamera.cameraController.setFlashMode(FlashMode.auto);
        emit(FlashModeAuto());
      }
    }
  }
}
