import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';

import 'directories_cubit.dart';

part 'list_files_state.dart';

class ListFilesCubit extends Cubit<ListFilesState> {
  ListFilesCubit({required this.directoriesCubit}) : super(ListFilesInitial());
  final DirectoriesCubit directoriesCubit;
  StreamSubscription? directoriesStates;
  Future<void> getFiles() async {
    ReceivePort receivePort = ReceivePort();
    DirectoriesState stateofDirectory = directoriesCubit.state;
    if (stateofDirectory is! DirectoriesLoaded) {
      emit(const ListFilesError(error: "Directories not loaded"));
      return;
    }

    Isolate isolate = await Isolate.spawn(_getRecentImage, [
      RootIsolateToken.instance!,
      receivePort.sendPort,
      stateofDirectory.documentsDirectory
    ]);
    List<String> data = await receivePort.first;
    if (data.isEmpty) {
      if (!isClosed) {
        emit(const ListFilesError(error: "No Files to Show"));
      }

      isolate.kill(priority: Isolate.immediate);
      return;
    }
    if (!isClosed) {
      emit(ListFilesLoaded(files: data));
    }

    isolate.kill(priority: Isolate.immediate);
  }

  static void _getRecentImage(List args) async {
    BackgroundIsolateBinaryMessenger.ensureInitialized(args[0]);
    DartPluginRegistrant.ensureInitialized();
    SendPort mainSendPort = args[1];
    String directoryPath = '${args[2]}/media/';
    Directory(directoryPath).createSync(recursive: false);
    Directory directory = Directory(directoryPath);
    List<String> files = [];
    List<FileSystemEntity> fileList = await directory.list().toList();
    for (var file in fileList) {
      if (file.path.contains('.jpg') || file.path.contains('.mp4')) {
        files.add(file.path);
      }
    }

    mainSendPort.send(files);
  }

  @override
  Future<void> close() {
    directoriesStates?.cancel();
    return super.close();
  }
}
