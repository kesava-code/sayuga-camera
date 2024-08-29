part of 'watermark_cubit.dart';

abstract class WatermarkState {
  const WatermarkState();
}

class WatermarkLoading extends WatermarkState {}

class WatermarkLoaded extends WatermarkState {
  final String place;
  final String pin;
  final String timeStamp;
  WatermarkLoaded({this.place = "", this.pin = "",this.timeStamp= ""});
}

class WatermarkError extends WatermarkState {
  final String error;
  WatermarkError({required this.error});
}
