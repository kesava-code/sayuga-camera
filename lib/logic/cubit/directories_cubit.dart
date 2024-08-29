import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:path_provider/path_provider.dart';

part 'directories_state.dart';

class DirectoriesCubit extends Cubit<DirectoriesState> {
  DirectoriesCubit() : super(DirectoriesInitial()) {
    _getDirectories();
  }
  void _getDirectories() async {
    ReceivePort receivePort = ReceivePort();
    Isolate isolate = await Isolate.spawn(
        _appDirectory, [RootIsolateToken.instance!, receivePort.sendPort]);
    Map response = await receivePort.first;
    if (response["isError"]) {
      emit(DirectoriesError(error: response["error"]));
      isolate.kill(priority: Isolate.immediate);
      return;
    }

    emit(DirectoriesLoaded(
        temporaryDirectory: response['tempDir'],
        documentsDirectory: response['docDir']));
    isolate.kill(priority: Isolate.immediate);
  }

  static void _appDirectory(List args) async {
    BackgroundIsolateBinaryMessenger.ensureInitialized(args[0]);
    DartPluginRegistrant.ensureInitialized();
    SendPort mainPort = args[1];
    // Use a plugin to get some new value to send back to the main isolate.
    try {
      final Directory dir = await getApplicationDocumentsDirectory();
      final Directory tempDir = await getTemporaryDirectory();
      Map path = {};
      path["isError"] = false;
      path["docDir"] = dir.path;
      path['tempDir'] = tempDir.path;
      mainPort.send(path);
    } catch (e) {
      Map path = {};
      path["isError"] = true;
      path["error"] = e.toString();
    }
  }

  @override
  void onChange(Change<DirectoriesState> change) {
    // TODO: implement onChange
    if (kDebugMode) {
      print(change);
    }
    super.onChange(change);
  }
}
