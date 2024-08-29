import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

part 'internet_state.dart';

class InternetCubit extends Cubit<InternetState> {
  final Connectivity connectivity;
  final InternetConnectionChecker internetChecker;
  StreamSubscription? connectivityStream;
  bool isDeviceConnected = false;
  InternetCubit({required this.connectivity, required this.internetChecker})
      : super(InternetLoading()) {
    checkConectivity();
  }

  Future<void> checkConectivity() async {
    connectivityStream = connectivity.onConnectivityChanged
        .listen((ConnectivityResult result) async {
      if (result != ConnectivityResult.none) {
        isDeviceConnected = await internetChecker.hasConnection;
        if (isDeviceConnected == true) {
          emit(InternetConnected());
          
        } else {
          emit(InternetDisconnected());
        }
      }
    });
  }

  @override
  Future<void> close() {
    connectivityStream?.cancel();
    return super.close();
  }
}
