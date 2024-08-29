part of 'location_cubit.dart';

abstract class LocationState {
  const LocationState();
}

class LocationLoading extends LocationState {}

class LocationLoaded extends LocationState {
  final String place;
  final String pin;
  LocationLoaded({this.place = "",this.pin = ""});
}

class LocationError extends LocationState {
  final String error;
  LocationError({required this.error});
}
