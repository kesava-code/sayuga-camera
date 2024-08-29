part of 'timestamp_cubit.dart';

abstract class TimestampState {
  const TimestampState();
}

class TimestampLoading extends TimestampState {}

class Timestamp extends TimestampState {
  final String timestamp;
  Timestamp({required this.timestamp});
}
