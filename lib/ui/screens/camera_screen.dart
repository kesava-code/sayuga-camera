import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:sayuga/logic/cubit/camera_cubit.dart';
import 'package:sayuga/logic/cubit/camera_mode_cubit.dart';
import 'package:sayuga/logic/cubit/directories_cubit.dart';
import 'package:sayuga/logic/cubit/flash_mode_cubit.dart';
import 'package:sayuga/logic/cubit/image_cubit.dart';
import 'package:sayuga/logic/cubit/location_cubit.dart';
import 'package:sayuga/logic/cubit/pixel_ratio_cubit.dart';
import 'package:sayuga/logic/cubit/refreshcapturedimages_cubit.dart';
import 'package:sayuga/logic/cubit/timestamp_cubit.dart';
import 'package:sayuga/logic/cubit/video_cubit.dart';
import 'package:sayuga/logic/cubit/watermark_cubit.dart';
import 'package:sayuga/ui/screens/image_details_page.dart';
import 'package:sayuga/ui/screens/video_details_page.dart';
import 'package:sayuga/utils/camera_utils.dart';
import 'package:sayuga/utils/font_size.dart';
import 'package:sayuga/utils/thumbnail_generator.dart';
import 'package:sayuga/utils/viewclipper.dart';

import 'dart:io';
import 'package:video_player/video_player.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraUtils? cameraUtils;
  CameraCubit? cameraCubit;
  RefreshcapturedimagesCubit? refreshCapturedImagesCubit;
  double _currentZoomLevel = 1.0;
  VideoPlayerController? videoController;

  showInSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  //Future<void> _startVideoPlayer() async {
  //if (_videoFile != null) {
  //videoController = VideoPlayerController.file(_videoFile!);
  //await videoController!.initialize().then((_) {
  //// Ensure the first frame is shown after the video is initialized,
  //// even before the play button has been pressed.
  //if (mounted) {
  //setState(() {});
  //}
  //});
  //await videoController!.setLooping(false);
  //}
  //}

  //void setimg(Map res) {
  //if (res['v'] == 1) {
  //GallerySaver.saveVideo(res['s']);
  //if (mounted) {
  //setState(() {
  //_videoFile = File(res['s'].toString());
//
  //_imageFile = null;
  //});
  //}
  //} else if (res['v'] == 2) {
  //GallerySaver.saveImage(res['s']);
  //if (mounted) {
  //setState(() {
  //_imageFile = File(res['s'].toString());
//
  //_videoFile = null;
  //});
  //}
  //}
  //refreshimgisolate.kill('refreshimg');
  //}

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      BlocProvider.of<CameraCubit>(context).stopCamera();
    } else if (state == AppLifecycleState.resumed) {
      BlocProvider.of<CameraCubit>(context).startCamera();
    } else if (state == AppLifecycleState.paused) {
      BlocProvider.of<CameraCubit>(context).stopCamera();
    }
  }

  @override
  void dispose() {
    cameraCubit?.close();
    refreshCapturedImagesCubit?.close();
    videoController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // Hide the status bar in Android
    cameraUtils = CameraUtils();
    cameraCubit = CameraCubit(cameraUtils: cameraUtils!);
    refreshCapturedImagesCubit = RefreshcapturedimagesCubit(
        directoriesCubit: BlocProvider.of<DirectoriesCubit>(context));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double pixelRatio = View.of(context).devicePixelRatio;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          lazy: false,
          create: (context) => cameraCubit!,
        ),
        BlocProvider(
          create: (context) => refreshCapturedImagesCubit!,
          lazy: false,
        ),
        BlocProvider(lazy: false, create: (context) => TimestampCubit()),
        BlocProvider(
            lazy: false,
            create: (context) => WatermarkCubit(
                locationCubit: BlocProvider.of<LocationCubit>(context),
                timestampCubit: BlocProvider.of<TimestampCubit>(context))),
        BlocProvider(
            lazy: false,
            create: (context) => FlashModeCubit(
                cameraCubit: BlocProvider.of<CameraCubit>(context))),
        BlocProvider(
            lazy: false,
            create: ((context) => PixelRatioCubit(pixelRatio: pixelRatio))),
        BlocProvider(
          lazy: false,
          create: (context) => ImageCubit(
              refreshcapturedimagesCubit:
                  BlocProvider.of<RefreshcapturedimagesCubit>(context),
              directoriesCubit: BlocProvider.of<DirectoriesCubit>(context),
              cameraCubit: BlocProvider.of<CameraCubit>(context),
              watermarkCubit: BlocProvider.of<WatermarkCubit>(context),
              pixelRatioCubit: BlocProvider.of<PixelRatioCubit>(context)),
        ),
        BlocProvider(
            lazy: false,
            create: (context) => VideoCubit(
                directoriesCubit: BlocProvider.of<DirectoriesCubit>(context),
                refreshcapturedimagesCubit:
                    BlocProvider.of<RefreshcapturedimagesCubit>(context),
                cameraCubit: BlocProvider.of<CameraCubit>(context),
                watermarkCubit: BlocProvider.of<WatermarkCubit>(context))),
        BlocProvider(lazy: false, create: ((context) => CameraModeCubit())),
      ],
      child: Builder(builder: (context) {
        return Stack(children: <Widget>[
          BlocBuilder<CameraCubit, CameraState>(
            builder: (context, state) {
              if (state is CameraInitialized) {
                return ClipRect(
                  clipper: MediaSizeClipper(MediaQuery.of(context).size),
                  child: Transform.scale(
                    scale: 1 /
                        (state.cameraController.value.aspectRatio *
                            MediaQuery.of(context).size.aspectRatio),
                    alignment: Alignment.topLeft,
                    child: CameraPreview(state.cameraController),
                  ),
                );
              } else if (state is CameraLoading) {
                return const Center(
                    child: SpinKitSpinningLines(
                  color: Color.fromARGB(255, 209, 200, 188),
                  size: 50.0,
                ));
              } else if (state is CameraFailed) {
                return Expanded(
                  child: Center(
                    child: Text(
                      state.error,
                      style: const TextStyle(
                          color: Color(0xFF004a7c),
                          fontSize: 20,
                          fontFamily: 'cousine'),
                    ),
                  ),
                );
              } else {
                return Center(
                    child: TextButton(
                  onPressed: () {
                    BlocProvider.of<CameraCubit>(context).startCamera();
                  },
                  child: const Text(
                    "Open Camera",
                  ),
                ));
              }
            },
          ),
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  BlocBuilder<WatermarkCubit, WatermarkState>(
                    builder: (context, state) {
                      if (state is WatermarkLoaded) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "${state.place}\n${state.pin}\n\n${state.timeStamp}",
                            textScaleFactor: 1.0,
                            style: TextStyle(
                                overflow: TextOverflow.clip,
                                color: const Color.fromARGB(255, 255, 230, 0)
                                    .withOpacity(1),
                                fontFamily: 'comfortaa',
                                fontSize: FontSize.logicalFontSize),
                          ),
                        );
                      } else if (state is WatermarkError) {
                        return Text(
                          state.error,
                          style: TextStyle(
                            overflow: TextOverflow.clip,
                            color: const Color(0xFFFFE600).withOpacity(1),
                            fontFamily: 'comfortaa',
                            fontSize: FontSize.logicalFontSize,
                          ),
                        );
                      } else {
                        return Text(
                          "Loading...",
                          style: TextStyle(
                            overflow: TextOverflow.clip,
                            color: const Color.fromARGB(255, 255, 230, 0)
                                .withOpacity(1),
                            fontFamily: 'comfortaa',
                            fontSize: FontSize.logicalFontSize,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              //2nd row starts
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () {
                            BlocProvider.of<FlashModeCubit>(context)
                                .changeMode();
                          },
                          icon: BlocBuilder<FlashModeCubit, FlashModeState>(
                            builder: (context, state) {
                              if (state is FlashModeAuto) {
                                return const Icon(Icons.flash_auto_rounded);
                              } else if (state is FlashModeOff) {
                                return const Icon(Icons.flash_off_rounded);
                              } else {
                                return const Icon(Icons.highlight_rounded);
                              }
                            },
                          ),
                          style: IconButton.styleFrom(
                            iconSize: 30,
                            foregroundColor: Colors.amber,
                            backgroundColor: Colors.grey.withOpacity(0.2),
                            highlightColor: Colors.black.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: BlocBuilder<CameraCubit, CameraState>(
                      builder: (context, state) {
                        if (state is CameraInitialized) {
                          return Slider(
                            value: _currentZoomLevel,
                            min: state.minAvailableZoom,
                            max: state.maxAvailableZoom,
                            activeColor: Colors.white,
                            inactiveColor: Colors.white30,
                            onChanged: (value) async {
                              if (mounted) {
                                setState(() {
                                  _currentZoomLevel = value;
                                });
                              }
                              await state.cameraController.setZoomLevel(value);
                            },
                          );
                        } else {
                          return const SizedBox(
                            height: 0,
                          );
                        }
                      },
                    ),
                  ),
                  Container(
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        '${_currentZoomLevel.toStringAsFixed(1)}x',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  BlocBuilder<RefreshcapturedimagesCubit,
                      RefreshcapturedimagesState>(
                    builder: (context, state) {
                      if (state is RefreshcapturedimagesJPEG) {
                        return Hero(
                          tag: 9949,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(50.0),
                                border:
                                    Border.all(color: Colors.white, width: 1),
                                image: DecorationImage(
                                  image: FileImage(File(state.filename)),
                                  fit: BoxFit.cover,
                                )),
                            child: RawMaterialButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailsPage(
                                        imagePath: state.filename, tag: 9949),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }
                      if (state is RefreshcapturedimagesMP4) {
                        return FutureBuilder(
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.hasError) {
                                return Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(50.0),
                                    border: Border.all(
                                        color: Colors.white, width: 1),
                                  ),
                                );
                              }
                              if (snapshot.hasData) {
                                final data = snapshot.data as Uint8List;
                                return Hero(
                                  tag: 9950,
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius:
                                            BorderRadius.circular(50.0),
                                        border: Border.all(
                                            color: Colors.white, width: 1),
                                        image: DecorationImage(
                                          image: MemoryImage(data),
                                          fit: BoxFit.cover,
                                        )),
                                    child: RawMaterialButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                VideoDetailsPage(
                                              videoPath: state.filename,
                                              tag: 9950,
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Icon(
                                        Icons.play_arrow_rounded,
                                        color:
                                            Color.fromARGB(190, 189, 189, 189),
                                        size: 35,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            }
                            return Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(50.0),
                                border:
                                    Border.all(color: Colors.white, width: 1),
                              ),
                              child: const CupertinoActivityIndicator(),
                            );
                          },
                          future: ThumbnailGenerator(videoPath: state.filename)
                              .getThumbnail(),
                        );
                      }

                      return Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(50.0),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                      );
                    },
                  ),
                  BlocBuilder<CameraModeCubit, CameraModeState>(
                    builder: (context, state) {
                      if (state is CameraModePhoto) {
                        return IconButton(
                          onPressed: () {
                            BlocProvider.of<ImageCubit>(context).takePicture();
                          },
                          icon: const Icon(Icons.circle),
                          style: IconButton.styleFrom(
                              shape: const CircleBorder(
                                  side: BorderSide(
                                color: Colors.black87,
                              )),
                              iconSize: 2,
                              padding: const EdgeInsets.all(35.0),
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.white,
                              highlightColor: Colors.grey.withOpacity(0.2)),
                        );
                      } else {
                        return BlocBuilder<VideoCubit, VideoState>(
                          builder: (context, videoState) {
                            if (videoState is VideoRecording) {
                              return IconButton(
                                onPressed: () {
                                  BlocProvider.of<VideoCubit>(context)
                                      .saveVideo();
                                },
                                icon: const Icon(Icons.square_rounded),
                                style: IconButton.styleFrom(
                                    iconSize: 30,
                                    padding: const EdgeInsets.all(21.0),
                                    foregroundColor: Colors.red,
                                    backgroundColor:
                                        Colors.white.withOpacity(0.8),
                                    highlightColor:
                                        Colors.grey.withOpacity(0.2)),
                              );
                            } else {
                              return IconButton(
                                onPressed: () {
                                  BlocProvider.of<VideoCubit>(context)
                                      .startVideoRecording();
                                },
                                icon: const Icon(Icons.circle),
                                style: IconButton.styleFrom(
                                    iconSize: 68,
                                    padding: const EdgeInsets.all(2.0),
                                    foregroundColor: Colors.red,
                                    backgroundColor:
                                        Colors.white.withOpacity(0.5),
                                    highlightColor:
                                        Colors.grey.withOpacity(0.2)),
                              );
                            }
                          },
                        );
                      }
                    },
                  ),
                  BlocBuilder<CameraCubit, CameraState>(
                    builder: (context, state) {
                      if (state is CameraInitialized) {
                        return IconButton(
                          onPressed: () {
                            if (state.rearCameraSelected) {
                              BlocProvider.of<CameraCubit>(context)
                                  .startCamera(cameraDirection: 1);
                            } else {
                              BlocProvider.of<CameraCubit>(context)
                                  .startCamera();
                            }
                          },
                          icon: const Icon(Icons.flip_camera_ios_rounded),
                          style: IconButton.styleFrom(
                            iconSize: 35,
                            backgroundColor: Colors.black.withOpacity(0.2),
                            foregroundColor: Colors.white,
                            highlightColor: Colors.grey.withOpacity(0.2),
                          ),
                        );
                      } else {
                        return const SizedBox();
                      }
                    },
                  )
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 8.0,
                        right: 4.0,
                      ),
                      child: BlocBuilder<CameraModeCubit, CameraModeState>(
                          builder: (context, state) {
                        if (state is CameraModePhoto) {
                          return TextButton(
                            onPressed: null,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.white,
                            ),
                            child: const Text('IMAGE'),
                          );
                        } else {
                          return TextButton(
                            onPressed: () {
                              VideoState stateofVideo =
                                  BlocProvider.of<VideoCubit>(context).state;
                              if (stateofVideo is! VideoRecording) {
                                BlocProvider.of<CameraModeCubit>(context)
                                    .changeMode();
                              }
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black54,
                              backgroundColor: Colors.white30,
                            ),
                            child: const Text('IMAGE'),
                          );
                        }
                      }),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4.0, right: 8.0),
                      child: BlocBuilder<CameraModeCubit, CameraModeState>(
                          builder: (context, state) {
                        if (state is CameraModeVideo) {
                          return TextButton(
                            onPressed: null,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.white,
                            ),
                            child: const Text('Video'),
                          );
                        } else {
                          return TextButton(
                            onPressed: () {
                              BlocProvider.of<CameraModeCubit>(context)
                                  .changeMode();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black54,
                              backgroundColor: Colors.white30,
                            ),
                            child: const Text('VIDEO'),
                          );
                        }
                      }),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ]);
      }),
    );
  }
}
