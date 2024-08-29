import 'dart:convert';

import 'package:http/http.dart' as http;

class PostAPI {
  Future<dynamic> fetchPosts() async {
    var uri = Uri.parse("https://s1.sayuga.com/uploads/");
    var response = await http.get(uri);
    if (response.statusCode == 200) {
      return response.body;
    }

    final map = json.decode(response.body) as Map<String, dynamic>;
    String detail = map['detail'] as String;
    throw(detail);
  }
}
