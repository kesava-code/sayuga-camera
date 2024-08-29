import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

part 'timestamp_state.dart';

class TimestampCubit extends Cubit<TimestampState> {
  TimestampCubit() : super(TimestampLoading()) {
    emit(Timestamp(
        timestamp: DateFormat("hh:mm a  MMM, dd, yyyy")
            .format(DateTime.now())
            .toString()));
    _getCurrentTime();
  }

  void _getCurrentTime() {
    Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (!isClosed) {
        emit(Timestamp(
            timestamp: DateFormat("hh:mm a  MMM, dd, yyyy")
                .format(DateTime.now())
                .toString()));
      }
    });
  }
}
