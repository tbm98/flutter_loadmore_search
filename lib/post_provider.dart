import 'dart:async';

import 'package:flutter_loadmore_search/http_client.dart';
import 'package:flutter_loadmore_search/post.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final postsProvider = StateNotifierProvider<PostNotifier>((ref) {
  return PostNotifier();
});

class PostState {
  final int page;
  final bool isLoading;
  final bool isLoadMoreDone;
  final bool isLoadMoreError;
  final List<Post> posts;

  PostState(this.page, this.isLoading, this.isLoadMoreError,
      this.isLoadMoreDone, this.posts);
}

class PostNotifier extends StateNotifier<PostState> {
  PostNotifier() : super(PostState(1, true, false, false, null)) {
    _initPosts();
  }

  _initPosts([int initPage]) async {
    final page = initPage ?? state.page;
    final posts = await getPosts(page);

    if (posts == null) {
      state = PostState(page, false, false, false, posts);
      return;
    }

    print('get post is ${posts.length}');
    state = PostState(page, false, false, false, posts);
  }

  loadMorePost() async {
    if (state.isLoading) {
      return;
    }
    state = PostState(state.page, true, false, false, state.posts);

    final posts = await getPosts(state.page + 1);

    if (posts == null) {
      // error
      state = PostState(state.page, false, true, false, state.posts);
      return;
    }

    print('load more post is ${posts.length} at page ${state.page + 1}');
    state = PostState(state.page + 1, false, false, posts.length == 0,
        [...state.posts, ...posts]);
  }

  Future<void> refresh() async {
    _initPosts(1);
  }
}
