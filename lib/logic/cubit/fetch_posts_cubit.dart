import 'package:bloc/bloc.dart';
import 'package:sayuga/models/post_model.dart';
import 'package:sayuga/repository/posts_repository.dart';

part 'fetch_posts_state.dart';

class FetchPostsCubit extends Cubit<FetchPostsState> {
  FetchPostsCubit() : super(FetchPostsLoading()) {
    fetchPosts();
  }

  void fetchPosts() async {
    PostModel postData = await PostRepository().getPosts();
    if (postData.isError) {
      emit(FetchPostsError(error: postData.error!));
      return;
    }
    if (!isClosed) {
      emit(FetchPostsLoaded(posts: postData.urls!));
    }
  }
}
