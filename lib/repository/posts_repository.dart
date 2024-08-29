import 'dart:convert';
import 'dart:developer';

import 'package:sayuga/data/posts.dart';
import 'package:sayuga/models/post_model.dart';

class PostRepository {
  Future<PostModel> getPosts() async {
    try {
      String jsondata = await PostAPI().fetchPosts();
      return PostModel.fromJson(jsondata);
    } catch (e) {
      return PostModel(isError: true, error: e.toString());
    }
  }
}
