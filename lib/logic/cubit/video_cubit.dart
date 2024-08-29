import 'dart:io';

import 'package:camera/camera.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';

import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gallery_saver/gallery_saver.dart';

import 'package:sayuga/logic/cubit/camera_cubit.dart';
import 'package:sayuga/logic/cubit/directories_cubit.dart';
import 'package:sayuga/logic/cubit/refreshcapturedimages_cubit.dart';
import 'package:sayuga/logic/cubit/watermark_cubit.dart';

part 'video_state.dart';

class VideoCubit extends Cubit<VideoState> {
  final DirectoriesCubit directoriesCubit;
  final CameraCubit cameraCubit;
  final WatermarkCubit watermarkCubit;
  final RefreshcapturedimagesCubit refreshcapturedimagesCubit;
  VideoCubit(
      {required this.directoriesCubit,
      required this.refreshcapturedimagesCubit,
      required this.cameraCubit,
      required this.watermarkCubit})
      : super(VideoInitial());

  Future<void> saveVideo() async {
    DirectoriesState stateofDirectory = directoriesCubit.state;
    WatermarkState stateofWatermark = watermarkCubit.state;
    CameraState stateofCamera = cameraCubit.state;
    if (stateofDirectory is! DirectoriesLoaded) {
      emit(VideoRecordingError(error: "Directory path not found"));
    } else if (stateofCamera is! CameraInitialized) {
      emit(VideoRecordingError(error: "Camera not found"));
    } else if (stateofWatermark is! WatermarkLoaded) {
      emit(VideoRecordingError(error: "Watermark not found"));
    } else if (!stateofCamera.cameraController.value.isRecordingVideo) {
      // Recording is already is stopped state
      emit(VideoRecordingError(error: "No video recording"));
    } else {
      try {
        XFile? file = await stateofCamera.cameraController.stopVideoRecording();

        String directory = stateofDirectory.documentsDirectory;
        if (!File('$directory/Comfortaa-Bold.ttf').existsSync()) {
          String assetName = "Comfortaa-Bold.ttf";

          final ByteData assetByteData =
              await rootBundle.load('fonts/$assetName');

          final List<int> byteList = assetByteData.buffer.asUint8List(
              assetByteData.offsetInBytes, assetByteData.lengthInBytes);

          final String fullTemporaryPath = "$directory/$assetName";

          File(fullTemporaryPath)
              .writeAsBytes(byteList, mode: FileMode.writeOnly);
        }

        int currentUnix = DateTime.now().millisecondsSinceEpoch;

        List lastLine = stateofWatermark.timeStamp.toString().split(":");
        String finalLine = "${lastLine[0]}\\:${lastLine[1]}";
        String fontFile = "$directory/Comfortaa-Bold.ttf";

        emit(VideoInitial());

        await FFmpegKit.executeAsync(
            '''-i ${file.path} -vf "drawtext=text='${stateofWatermark.place}':fontfile='$fontFile':x=10:y=10:fontsize=20:fontcolor=Yellow,drawtext=text='${stateofWatermark.pin}':fontfile='$fontFile':x=10:y=40:fontsize=20:fontcolor=yellow,drawtext=text='$finalLine':fontfile='$fontFile':x=10:y=90:fontsize=20:fontcolor=yellow" -c:v libx264 -c:a copy "$directory/media/$currentUnix.mp4"''',
            (session) async {
          final returnCode = await session.getReturnCode();

          if (ReturnCode.isSuccess(returnCode)) {
            // SUCCESS
            GallerySaver.saveVideo('$directory/media/$currentUnix.mp4');
            emit(VideoRecorded());
            refreshcapturedimagesCubit.emit(RefreshcapturedimagesMP4(
                filename: '$directory/media/$currentUnix.mp4'));
          } else if (ReturnCode.isCancel(returnCode)) {
            // CANCEL
            emit(VideoRecordingError(error: "Cancelled Recording."));
          } else {
            emit(VideoRecordingError(error: "Error at Execution."));
          }
        });
      } on CameraException catch (e) {
        emit(VideoRecordingError(error: e.code));
      }
    }
  }

  void startVideoRecording() async {
    CameraState stateofCamera = cameraCubit.state;
    if (stateofCamera is CameraInitialized) {
      if (stateofCamera.cameraController.value.isRecordingVideo) {
        // A recording has already started, do nothing.
      } else {
        try {
          await stateofCamera.cameraController.startVideoRecording();
          emit(VideoRecording());
        } on CameraException catch (e) {
          emit(VideoRecordingError(error: e.code));
        }
      }
    }
  }
}
