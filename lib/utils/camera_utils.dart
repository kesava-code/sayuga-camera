import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class CameraUtils {
  Future<CameraController> getCameraController(
      {required int cameraDirection}) async {
    List<CameraDescription> cameras = [];
    try {
      cameras = await availableCameras();
    } on CameraException catch (e) {
      if (kDebugMode) {
        print('Error in fetching the cameras: $e');
      }
    }
    return CameraController(
      cameras[cameraDirection],
      ResolutionPreset.high,
    );
  }
}
