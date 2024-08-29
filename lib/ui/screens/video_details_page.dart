// ignore_for_file: deprecated_member_use
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sayuga/logic/cubit/upload_file_cubit.dart';
import 'package:video_player/video_player.dart';

class VideoDetailsPage extends StatefulWidget {
  final String videoPath;
  final int tag;
  const VideoDetailsPage({
    Key? key,
    required this.videoPath,
    required this.tag,
  }) : super(key: key);

  @override
  State<VideoDetailsPage> createState() => _VideoDetailsPageState();
}

class _VideoDetailsPageState extends State<VideoDetailsPage> {
  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();

    // Create and store the VideoPlayerController. The VideoPlayerController
    // offers several different constructors to play videos from assets, files,
    // or the internet.
    if (widget.videoPath.contains("http")) {
      _controller =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoPath));
      _controller!.setLooping(true);

      _initializeVideoPlayerFuture = _controller!.initialize();
    } else {
      _controller = VideoPlayerController.file(File(widget.videoPath));
      _controller!.setLooping(true);

      _initializeVideoPlayerFuture = _controller!.initialize();
    }
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controller?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color iconColor = Theme.of(context).primaryColorDark;
    return SafeArea(
      child: BlocProvider(
        create: (context) => UploadFileCubit(),
        child: Builder(builder: (context) {
          return Scaffold(
            appBar: AppBar(
              toolbarHeight: 35,
              actions: [
                !widget.videoPath.contains("http")
                    ? BlocBuilder<UploadFileCubit, UploadFileState>(
                        builder: (context, state) {
                          if (state is UploadFileUploading) {
                            return SizedBox(
                              width: 50,
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: CupertinoActivityIndicator(
                                  radius: 10,
                                  color: iconColor,
                                ),
                              ),
                            );
                          }
                          if (state is UploadFileUploaded) {
                            return SizedBox(
                              width: 50,
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: Icon(
                                  color: iconColor,
                                  size: 26,
                                  Icons.cloud_done_rounded,
                                ),
                              ),
                            );
                          }
                          if (state is UploadFileError) {
                            return IconButton(
                              color: iconColor,
                              iconSize: 26,
                              padding: const EdgeInsets.all(2),
                              icon: const Icon(
                                Icons.replay_circle_filled_outlined,
                              ),
                              onPressed: () {
                                BlocProvider.of<UploadFileCubit>(context)
                                    .uploadFile(filePath: widget.videoPath);
                              },
                            );
                          }
                          return IconButton(
                            color: iconColor,
                            iconSize: 26,
                            padding: const EdgeInsets.all(2),
                            onPressed: () {
                              BlocProvider.of<UploadFileCubit>(context)
                                  .uploadFile(filePath: widget.videoPath);
                            },
                            icon: const Icon(
                              Icons.cloud_upload_rounded,
                            ),
                          );
                        },
                      )
                    : const SizedBox(),
                !widget.videoPath.contains("http")
                    ? IconButton(
                        color: iconColor,
                        iconSize: 26,
                        padding: const EdgeInsets.all(2),
                        onPressed: () async {
                          await File(widget.videoPath)
                              .delete()
                              .then((value) => Navigator.of(context).pop(true));
                        },
                        icon: const Icon(Icons.delete))
                    : const SizedBox(),
              ],
            ),
            body: Column(
              children: <Widget>[
                Expanded(
                  child: Stack(children: [
                    Hero(
                      tag: widget.tag,
                      child: FutureBuilder(
                        future: _initializeVideoPlayerFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            // If the VideoPlayerController has finished initialization, use
                            // the data it provides to limit the aspect ratio of the video.
                            return Stack(children: [
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Center(
                                  child: FittedBox(
                                    clipBehavior: Clip.hardEdge,
                                    fit: BoxFit.cover,
                                    alignment: Alignment.topLeft,
                                    child: SizedBox(
                                        width: _controller!.value.size.width,
                                        height: _controller!.value.size.height,
                                        child: VideoPlayer(_controller!)),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: IconButton(
                                    color: const Color.fromARGB(
                                        154, 158, 158, 158),
                                    iconSize: 90,
                                    icon: Icon(_controller!.value.isPlaying
                                        ? Icons.pause_circle_outline_rounded
                                        : Icons.play_circle_outline_rounded),
                                    onPressed: () {
                                      setState(() {
                                        if (_controller!.value.isPlaying) {
                                          _controller!.pause();
                                        } else {
                                          _controller!.play();
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ]);
                          } else {
                            // If the VideoPlayerController is still initializing, show a
                            // loading spinner.
                            return const Center(
                              child: CupertinoActivityIndicator(),
                            );
                          }
                        },
                      ),
                    ),
                  ]),
                ),
                // child: Container(
                //   decoration: BoxDecoration(
                //     image: DecorationImage(
                //       image: FileImage(File(widget.videoPath)),
                //       fit: BoxFit.cover,
                //       alignment: Alignment.topLeft,
                //     ),
                //   ),
                // ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
