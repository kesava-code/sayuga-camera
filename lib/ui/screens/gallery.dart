import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sayuga/logic/cubit/directories_cubit.dart';
import 'package:sayuga/logic/cubit/list_files_cubit.dart';
import 'package:sayuga/ui/screens/video_details_page.dart';
import 'package:sayuga/utils/thumbnail_generator.dart';
import 'image_details_page.dart';

class Gallery extends StatefulWidget {
  const Gallery({Key? key}) : super(key: key);

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  ListFilesCubit? listFilesCubit;

  @override
  void initState() {
    listFilesCubit = ListFilesCubit(
        directoriesCubit: BlocProvider.of<DirectoriesCubit>(context))
      ..getFiles();
    super.initState();
  }

  @override
  void dispose() {
    listFilesCubit?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => listFilesCubit!,
      lazy: false,
      child: Builder(builder: (context) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 30,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: BlocBuilder<ListFilesCubit, ListFilesState>(
                      builder: (context, state) {
                        if (state is ListFilesLoaded) {
                          List<String> files = List.from(state.files.reversed);
                          return GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemBuilder: (context, index) {
                              return RawMaterialButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) {
                                      if (files[index].contains(".jpg")) {
                                        return DetailsPage(
                                          imagePath: files[index],
                                          tag: index,
                                        );
                                      }

                                      return VideoDetailsPage(
                                        videoPath: files[index],
                                        tag: index,
                                      );
                                    }),
                                  ).then((value) =>
                                      BlocProvider.of<ListFilesCubit>(context)
                                          .getFiles());
                                },
                                child: Hero(
                                  tag: index,
                                  child: Builder(builder: (context) {
                                    if (files[index].contains(".jpg")) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image:
                                                FileImage(File(files[index])),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      );
                                    } else {
                                      return FutureBuilder(
                                          future: ThumbnailGenerator(
                                                  videoPath: files[index])
                                              .getThumbnail(),
                                          builder: ((context, snapshot) {
                                            if (snapshot.hasError) {
                                              return const Icon(
                                                Icons.error_rounded,
                                                color: Color.fromRGBO(
                                                    214, 214, 214, 1),
                                              );
                                            }
                                            if (snapshot.connectionState ==
                                                ConnectionState.done) {
                                              if (snapshot.hasData) {
                                                return Stack(
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                          image: DecorationImage(
                                                              fit: BoxFit.cover,
                                                              alignment:
                                                                  Alignment
                                                                      .topLeft,
                                                              image: MemoryImage(
                                                                  snapshot.data
                                                                      as Uint8List))),
                                                    ),
                                                    Center(
                                                        child: Icon(
                                                      Icons.play_circle,
                                                      size: 40,
                                                      color: Colors.grey[400],
                                                    )),
                                                  ],
                                                );
                                              }
                                            }
                                            return const CupertinoActivityIndicator();
                                          }));
                                    }
                                  }),
                                ),
                              );
                            },
                            itemCount: files.length,
                          );
                        }
                        if (state is ListFilesError) {
                          return Center(child: Text(state.error));
                        }
                        return const Center(
                            child: CupertinoActivityIndicator(
                          radius: 20,
                        ));
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}
