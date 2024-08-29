import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'navigation_state.dart';

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(NavigationState(page: 0));

  void change({required int index}) {
    emit(NavigationState(page: index));
  }

  void bottomBarPressed({required int index}) {
    state.pageController.animateToPage(index,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    emit(NavigationState(page: index));
  }
}
