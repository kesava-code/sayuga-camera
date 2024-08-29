import 'dart:convert';

class PostModel {
  final bool isError;
  final List<String>? urls;
  final String? error;
  PostModel({this.error, this.isError = false, this.urls});

  factory PostModel.fromMap(List list) {
    return PostModel(
      urls: list.map((e) {
        Map map = e as Map<String, dynamic>;
        return map['file'] as String;
      }).toList(),
    );
  }

  factory PostModel.fromJson(dynamic source) =>
      PostModel.fromMap(json.decode(source) as List);
}
