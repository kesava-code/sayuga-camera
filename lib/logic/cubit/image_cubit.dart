import 'dart:io';
import 'dart:isolate';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image/image.dart' as ui;
import 'package:sayuga/utils/imageeditor.dart' as editor;

import 'package:camera/camera.dart';
import 'package:sayuga/logic/cubit/camera_cubit.dart';
import 'package:sayuga/logic/cubit/directories_cubit.dart';
import 'package:sayuga/logic/cubit/pixel_ratio_cubit.dart';
import 'package:sayuga/logic/cubit/refreshcapturedimages_cubit.dart';
import 'package:sayuga/logic/cubit/watermark_cubit.dart';
import 'package:sayuga/utils/font_size.dart';

part 'image_state.dart';

class ImageCubit extends Cubit<ImageState> {
  final RefreshcapturedimagesCubit refreshcapturedimagesCubit;
  final DirectoriesCubit directoriesCubit;
  final CameraCubit cameraCubit;
  final WatermarkCubit watermarkCubit;
  final PixelRatioCubit pixelRatioCubit;
  int fontSize = 20;
  ImageCubit(
      {required this.refreshcapturedimagesCubit,
      required this.directoriesCubit,
      required this.cameraCubit,
      required this.watermarkCubit,
      required this.pixelRatioCubit})
      : super(ImageInitial());

  Future<void> takePicture() async {
    DirectoriesState stateofDirectory = directoriesCubit.state;
    WatermarkState stateofWatermark = watermarkCubit.state;
    CameraState stateofCamera = cameraCubit.state;
    fontSize =
        (pixelRatioCubit.state.pixelRatio * FontSize.logicalFontSize).round();

    if (stateofDirectory is! DirectoriesLoaded) {
      emit(ImageSavingError(error: "Directory path not found"));
    } else if (stateofCamera is! CameraInitialized) {
      emit(ImageSavingError(error: "Camera not found"));
    } else if (stateofWatermark is! WatermarkLoaded) {
      emit(ImageSavingError(error: "Watermark not found"));
    } else if (stateofCamera.cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
    } else {
      try {
        stateofCamera.cameraController.takePicture().then((xfile) async {
          var receivePort = ReceivePort();
          final String path = xfile.path;

          await Isolate.spawn(
              _saveImage,
              Watermarkvariables(
                  fileLocation: path,
                  docdir: '${stateofDirectory.documentsDirectory}/media',
                  place: stateofWatermark.place,
                  pin: stateofWatermark.pin,
                  timeStamp: stateofWatermark.timeStamp,
                  sendPort: receivePort.sendPort,
                  fontSize: fontSize));
          String response = await receivePort.first as String;
          emit(ImageSaved(imagepath: response));
          refreshcapturedimagesCubit
              .emit(RefreshcapturedimagesJPEG(filename: response));
          GallerySaver.saveImage(response);
        });
      } on CameraException catch (e) {
        emit(ImageSavingError(error: e.code));

        return;
      }
    }
  }

  static void _saveImage(Watermarkvariables variables) async {
    // Use a plugin to get some new value to send back to the main isolate.
    String filepath = variables.fileLocation;
    String directorypath = variables.docdir;
    //int fontSize = variables.fontSize;
    await Directory(directorypath).create(recursive: false);
    final bytes = await File(filepath).readAsBytes();
    String place = variables.place;
    String pin = variables.pin;
    String timeStamp = variables.timeStamp;
    String space = " ";
    final List<int> font = FontSize.size20;
    final ui.BitmapFont fontNameSizeStyle = ui.BitmapFont.fromZip(font);
    final ui.Image image = ui.decodeJpg(bytes)!;
    final ui.Image mimage = editor.drawString(
      image,
      " $place \n $pin \n $space \n $timeStamp",
      font: fontNameSizeStyle,
      x: 10,
      y: 10,
      color: ui.ColorFloat16.rgba(191, 219, 56, 1),
    );
    // final ui.Image mimage = ui.drawString(
    //     image, fontNameSizeStyle, 5, 5, watermark,
    //     color: 0xFF00E6FF);
    int currentUnix = DateTime.now().millisecondsSinceEpoch;
    File('$directorypath/$currentUnix.jpg')
        .writeAsBytesSync(ui.encodeJpg(mimage));
    variables.sendPort.send('$directorypath/$currentUnix.jpg');
  }
}

class Watermarkvariables {
  final String place;
  final String pin;
  final String timeStamp;
  final String fileLocation;
  final SendPort sendPort;
  final String docdir;

  final int fontSize;
  Watermarkvariables(
      {required this.fileLocation,
      required this.docdir,
      required this.sendPort,
      required this.fontSize,
      required this.pin,
      required this.place,
      required this.timeStamp});
}
