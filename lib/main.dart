import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:sayuga/logic/cubit/directories_cubit.dart';
import 'package:sayuga/logic/cubit/internet_cubit.dart';
import 'package:sayuga/logic/cubit/navigation_cubit.dart';
import 'package:sayuga/ui/screens/post_screen.dart';
import 'logic/cubit/location_cubit.dart';
import 'ui/screens/camera_screen.dart';
import 'ui/screens/gallery.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
//geolocation
  runApp(MyApp(
    directoriesCubit: DirectoriesCubit(),
    connectivity: Connectivity(),
    internetChecker: InternetConnectionChecker(),
    navigation: NavigationCubit(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp(
      {Key? key,
      required this.directoriesCubit,
      required this.connectivity,
      required this.internetChecker,
      required this.navigation})
      : super(key: key);

  final DirectoriesCubit directoriesCubit;
  final Connectivity connectivity;
  final InternetConnectionChecker internetChecker;
  final NavigationCubit navigation;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  LocationCubit? locationCubit;
  @override
  void initState() {
    locationCubit = LocationCubit();
    super.initState();
  }

  @override
  void dispose() {
    locationCubit?.close();
    super.dispose();
  }

  List<BottomNavigationBarItem> buildBottomNavBarItems() {
    return [
      const BottomNavigationBarItem(
          icon: Icon(Icons.photo_camera_rounded), label: ''),
      const BottomNavigationBarItem(
        icon: Icon(Icons.photo_library_rounded),
        label: '',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.cloud_rounded),
        label: '',
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(lazy: false, create: (context) => widget.directoriesCubit),
        BlocProvider(
          lazy: false,
          create: (context) => widget.navigation,
        ),
        BlocProvider(
          lazy: false,
          create: (context) => InternetCubit(
            connectivity: widget.connectivity,
            internetChecker: widget.internetChecker,
          ),
        ),
        BlocProvider(
          lazy: false,
          create: (context) => locationCubit!,
        ),
      ],
      child: MaterialApp(
        title: 'Sayuga',
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: Colors.indigo[600],
          primarySwatch: Colors.indigo,
        ),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          extendBody: true,
          bottomNavigationBar: BlocBuilder<NavigationCubit, NavigationState>(
            builder: (context, state) {
              return BottomNavigationBar(
                iconSize: 30,
                selectedLabelStyle: const TextStyle(fontSize: 0),
                unselectedLabelStyle: const TextStyle(fontSize: 0),
                selectedItemColor: Colors.indigo[600],
                unselectedItemColor: Colors.black,
                currentIndex: state.page,
                items: buildBottomNavBarItems(),
                onTap: (page) {
                  BlocProvider.of<NavigationCubit>(context)
                      .bottomBarPressed(index: page);
                },
              );
            },
          ),
          body: SafeArea(
            child: BlocBuilder<NavigationCubit, NavigationState>(
              builder: (context, state) {
                return PageView(
                  controller: state.pageController,
                  onPageChanged: (index) {
                    BlocProvider.of<NavigationCubit>(context)
                        .change(index: index);
                  },
                  // ignore: prefer_const_literals_to_create_immutables
                  children: <Widget>[
                    const CameraScreen(),
                    const Gallery(),
                    const PostGallery()
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
