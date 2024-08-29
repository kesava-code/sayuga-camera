import 'dart:async';

import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sayuga/logic/cubit/directories_cubit.dart';

part 'refreshcapturedimages_state.dart';

class RefreshcapturedimagesCubit extends Cubit<RefreshcapturedimagesState> {
  final DirectoriesCubit directoriesCubit;
  StreamSubscription? directoriesStates;
  RefreshcapturedimagesCubit({required this.directoriesCubit})
      : super(RefreshcapturedimagesLoading()) {
    directoriesStates = directoriesCubit.stream.listen((event) {
      if (event is DirectoriesLoaded) {
        refreshImageIsolate();
      }
    });
  }

  Future<void> refreshImageIsolate() async {
    ReceivePort receivePort = ReceivePort();
    DirectoriesState stateofDirectory = directoriesCubit.state;
    if (stateofDirectory is! DirectoriesLoaded) {
      emit(RefreshcapturedimagesError(error: "Directories not loaded"));
      return;
    }

    Isolate isolate = await Isolate.spawn(_getRecentImage, [
      RootIsolateToken.instance!,
      receivePort.sendPort,
      stateofDirectory.documentsDirectory
    ]);
    Map data = await receivePort.first;
    switch (data['v']) {
      case 1:
        emit(RefreshcapturedimagesMP4(filename: data['s']));
        break;
      case 2:
        emit(RefreshcapturedimagesJPEG(filename: data['s']));
        break;
      case 0:
        emit(RefreshcapturedimagesEmpty());
        break;
      default:
        break;
    }
    isolate.kill(priority: Isolate.immediate);
  }

  static void _getRecentImage(List args) async {
    BackgroundIsolateBinaryMessenger.ensureInitialized(args[0]);
    DartPluginRegistrant.ensureInitialized();
    SendPort mainSendPort = args[1];
    String directoryPath = '${args[2]}/media';
    Directory(directoryPath).createSync(recursive: false);
    Directory directory = Directory(directoryPath);

    List<FileSystemEntity> fileList = await directory.list().toList();
    List<Map<int, dynamic>> fileNames = [];

    for (var file in fileList) {
      if (file.path.contains('.jpg') || file.path.contains('.mp4')) {
        String name = file.path.split('/').last.split('.').first;
        fileNames.add({0: int.parse(name), 1: file.path.split('/').last});
      }
    }
    Map details = {};
    if (fileNames.isNotEmpty) {
      Map details = {};
      final recentFile =
          fileNames.reduce((curr, next) => curr[0] > next[0] ? curr : next);
      String recentFileName = recentFile[1];

      if (recentFileName.contains('.mp4')) {
        details['s'] = "${directory.path}/$recentFileName";
        details['v'] = 1;

        mainSendPort.send(details);
      } else {
        details['s'] = "${directory.path}/$recentFileName";
        details['v'] = 2;
        mainSendPort.send(details);
      }
    } else {
      details['v'] = 0;
      mainSendPort.send(details);
    }
  }

  @override
  Future<void> close() {
    directoriesStates?.cancel();
    return super.close();
  }

  @override
  void onChange(Change<RefreshcapturedimagesState> change) {
    // TODO: implement onChange
    if (kDebugMode) {
      print(change);
    }
    super.onChange(change);
  }
}
