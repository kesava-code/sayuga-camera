part of 'camera_mode_cubit.dart';

abstract class CameraModeState extends Equatable {
  const CameraModeState();

  @override
  List<Object> get props => [];
}

class CameraModePhoto extends CameraModeState {}
class CameraModeVideo extends CameraModeState {}
