import 'package:bloc/bloc.dart';


part 'pixel_ratio_state.dart';

class PixelRatioCubit extends Cubit<PixelRatioState> {
  PixelRatioCubit({required double pixelRatio}) : super(PixelRatioState(pixelRatio: pixelRatio));
}
