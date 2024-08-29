import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'camera_mode_state.dart';

class CameraModeCubit extends Cubit<CameraModeState> {
  CameraModeCubit() : super(CameraModePhoto());

  void changeMode() {
    if (state is CameraModePhoto) {
      emit(CameraModeVideo());
    } else {
      emit(CameraModePhoto());
    }
  }
}
