import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

part 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  LocationCubit() : super(LocationLoading()) {
    _geoLocation();
  }

  void _geoLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      emit(LocationError(error: "Please turn on GPS or Location Services"));
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        emit(LocationError(error: "Please allow geolocation permissions"));
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      emit(LocationError(error: "Please enable location in settings"));
      return;
    }
    _getLocation();
  }

  void _getLocation() async {
    ReceivePort receivePort = ReceivePort();
    Isolate isolate = await Isolate.spawn(
        _locate, [RootIsolateToken.instance!, receivePort.sendPort]);
    Map response = await receivePort.first;
    if (response.containsKey('error')) {
      emit(LocationError(error: "We have trouble finding your location."));
    } else {
      emit(LocationLoaded(place: response['place'], pin: response['pin']));
    }
    isolate.kill(priority: Isolate.immediate);
  }

  static void _locate(List args) async {
    BackgroundIsolateBinaryMessenger.ensureInitialized(args[0]);
    DartPluginRegistrant.ensureInitialized();
    SendPort mainPort = args[1];
    try {
      Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      List<Placemark> placemark =
          await placemarkFromCoordinates(pos.latitude, pos.longitude);
      String place = "";
      String pin = "";
      placemark[0].subThoroughfare.toString() != ""
          ? place = "$place${placemark[0].subThoroughfare}, "
          : place = place;
      placemark[0].thoroughfare.toString() != ""
          ? place = "$place${placemark[0].thoroughfare}, "
          : place = place;
      placemark[0].locality.toString() != ""
          ? place = "$place${placemark[0].locality}, "
          : place = place;
      placemark[0].administrativeArea.toString() != ""
          ? place = "$place${placemark[0].administrativeArea}, "
          : place = place;
      placemark[0].postalCode.toString() != ""
          ? pin = "$pin${placemark[0].postalCode}, "
          : pin = pin;
      placemark[0].country.toString() != ""
          ? pin = "$pin${placemark[0].country}"
          : pin = pin;
      Map finalPlace = {};
      finalPlace['place'] = place;
      finalPlace['pin'] = pin;

      mainPort.send(finalPlace);
    } catch (e) {
      Map finalPlace = {};
      finalPlace['error'] = "false";
      mainPort.send(finalPlace);
    }
  }

  @override
  void onChange(Change<LocationState> change) {
    super.onChange(change);
    if (kDebugMode) {
      print(change);
    }
  }
}
