import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sayuga/logic/cubit/location_cubit.dart';
import 'package:sayuga/logic/cubit/timestamp_cubit.dart';

part 'watermark_state.dart';

class WatermarkCubit extends Cubit<WatermarkState> {
  final TimestampCubit timestampCubit;
  final LocationCubit locationCubit;
  StreamSubscription? timestampStates;
  StreamSubscription? locationStates;

  WatermarkCubit({required this.locationCubit, required this.timestampCubit})
      : super(WatermarkLoading()) {
    timestampStates = timestampCubit.stream.listen((event) {
      if (event is Timestamp) {
        LocationState stateofLocation = locationCubit.state;
        if (stateofLocation is! LocationLoaded) {
          emit(WatermarkLoaded(
              place: "Loading Location", timeStamp: event.timestamp));
          return;
        }

        emit(WatermarkLoaded(
            place: stateofLocation.place,
            pin: stateofLocation.pin,
            timeStamp: event.timestamp));
      }
    });
    locationStates = locationCubit.stream.listen((event) {
      if (event is LocationLoaded) {
        TimestampState stateofTimestamp = timestampCubit.state;
        if (stateofTimestamp is! Timestamp) {
          emit(WatermarkLoaded(
              pin: event.pin, place: event.place, timeStamp: "Loading Time"));
          return;
        }
         emit(WatermarkLoaded(
              pin: event.pin, place: event.place, timeStamp: stateofTimestamp.timestamp));
        return;
      }
      if (event is LocationError) {
        emit(WatermarkError(error: event.error));
      }
    });
  }

  @override
  Future<void> close() {
    timestampStates?.cancel();
    locationStates?.cancel();
    return super.close();
  }
}
