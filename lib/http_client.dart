import 'dart:convert';

import 'package:flutter_loadmore_search/post.dart';
import 'package:http/http.dart' as http;

Future<List<Post>> getPosts(int page) async {
  // đoạn if phía dưới để fake load lần đầu lỗi khi page = 1
  // if (page == 1) {
  //   // load more error
  //   await Future.delayed(Duration(seconds: 2));
  //   return null;
  // }

  // đoạn if phía dưới để fake load more fail khi page = 3
  // if (page == 3) {
  //   // load more error
  //   await Future.delayed(Duration(seconds: 2));
  //   return null;
  // }
  try {
    final response = await http.get(
        'https://jsonplaceholder.typicode.com/posts?_page=$page&_limit=10');
    final List<Post> posts = (jsonDecode(response.body) as List)
        .map((e) => Post.fromJsonMap(e))
        .toList();
    return posts;
  } catch (ex, st) {
    print(ex);
    print(st);
    return null;
  }
}
