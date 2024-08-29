part of 'navigation_cubit.dart';

class NavigationState extends Equatable {
  final PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );
  final int page;
  NavigationState({required this.page});

  @override
  List<Object?> get props => [page, pageController];
}
