import 'dart:convert';

import 'package:flutter_loadmore_search/post.dart';
import 'package:http/http.dart' as http;

Future<List<Post>> getPosts(int page) async {
  print('loading page $page');

  // fake loading error at page = 1
  // if (page == 1) {
  //   // load more error
  //   await Future.delayed(Duration(seconds: 2));
  //   return null;
  // }

  // fake load more error at page = 3
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
