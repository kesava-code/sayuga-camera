// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sayuga/logic/cubit/upload_file_cubit.dart';

class DetailsPage extends StatelessWidget {
  final String imagePath;
  final int tag;
  const DetailsPage({
    Key? key,
    required this.imagePath,
    required this.tag,
  }) : super(key: key);
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
                !imagePath.contains("http")
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
                                    .uploadFile(filePath: imagePath);
                              },
                            );
                          }
                          return IconButton(
                            color: iconColor,
                            iconSize: 26,
                            padding: const EdgeInsets.all(2),
                            onPressed: () {
                              BlocProvider.of<UploadFileCubit>(context)
                                  .uploadFile(filePath: imagePath);
                            },
                            icon: const Icon(
                              Icons.cloud_upload_rounded,
                            ),
                          );
                        },
                      )
                    : const SizedBox(),
                !imagePath.contains("http")
                    ? IconButton(
                        color: iconColor,
                        iconSize: 26,
                        padding: const EdgeInsets.all(2),
                        onPressed: () async {
                          await File(imagePath)
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
                      tag: tag,
                      child: imagePath.contains("http")
                          ? Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(imagePath),
                                  fit: BoxFit.cover,
                                  alignment: Alignment.topLeft,
                                ),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: FileImage(File(imagePath)),
                                  fit: BoxFit.cover,
                                  alignment: Alignment.topLeft,
                                ),
                              ),
                            ),
                    ),
                  ]),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
