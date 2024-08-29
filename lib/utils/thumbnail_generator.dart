import 'dart:typed_data';

import 'package:video_thumbnail/video_thumbnail.dart';

class ThumbnailGenerator {
  final String videoPath;
  ThumbnailGenerator({required this.videoPath});
  Future<Uint8List> getThumbnail() async {
    Uint8List? uint8list = await VideoThumbnail.thumbnailData(
      video: videoPath,
      imageFormat: ImageFormat.JPEG,
      maxWidth:
          128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 50,
    );
    return uint8list!;
  }
}
