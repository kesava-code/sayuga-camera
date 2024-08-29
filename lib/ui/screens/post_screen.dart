import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sayuga/logic/cubit/fetch_posts_cubit.dart';
import 'package:sayuga/ui/screens/video_details_page.dart';
import 'package:sayuga/utils/thumbnail_generator.dart';
import 'image_details_page.dart';

class PostGallery extends StatefulWidget {
  const PostGallery({Key? key}) : super(key: key);

  @override
  State<PostGallery> createState() => _PostGalleryState();
}

class _PostGalleryState extends State<PostGallery> {
  FetchPostsCubit? fetchPostsCubit;

  @override
  void initState() {
    fetchPostsCubit = FetchPostsCubit();
    super.initState();
  }

  @override
  void dispose() {
    fetchPostsCubit?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => fetchPostsCubit!,
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
                    child: BlocBuilder<FetchPostsCubit, FetchPostsState>(
                      builder: (context, state) {
                        if (state is FetchPostsLoaded) {
                          List<String> files = state.posts;
                          return GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemBuilder: (context, index) {
                              String path =
                                  "https://s1.sayuga.com${files[index]}";
                              return RawMaterialButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) {
                                      if (files[index].contains(".jpg")) {
                                        return DetailsPage(
                                          imagePath: path,
                                          tag: index,
                                        );
                                      }

                                      return VideoDetailsPage(
                                        videoPath: path,
                                        tag: index,
                                      );
                                    }),
                                  );
                                },
                                child: Hero(
                                  tag: index,
                                  child: Builder(builder: (context) {
                                    if (files[index].contains(".jpg")) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage(path, scale: 1),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      );
                                    } else {
                                      return FutureBuilder(
                                          future: ThumbnailGenerator(
                                                  videoPath: path)
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
                        if (state is FetchPostsError) {
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
