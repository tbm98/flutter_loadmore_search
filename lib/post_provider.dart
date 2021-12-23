import 'dart:async';

import 'package:flutter_loadmore_search/http_client.dart';
import 'package:flutter_loadmore_search/post.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_provider.freezed.dart';

@freezed
abstract class PostState with _$PostState {
  const factory PostState({
    @Default(1) int page,
    List<Post> posts,
    @Default(true) bool isLoading,
    @Default(false) bool isLoadMoreError,
    @Default(false) bool isLoadMoreDone,
  }) = _PostState;

  const PostState._();
}

final postsProvider = StateNotifierProvider<PostNotifier, PostState>((ref) {
  return PostNotifier();
});

class PostNotifier extends StateNotifier<PostState> {
  PostNotifier() : super(PostState()) {
    _initPosts();
  }

  _initPosts([int initPage]) async {
    final page = initPage ?? state.page;
    final posts = await getPosts(page);

    if (posts == null) {
      state = state.copyWith(page: page, isLoading: false);
      return;
    }

    print('get post is ${posts.length}');
    state = state.copyWith(page: page, isLoading: false, posts: posts);
  }

  loadMorePost() async {
    StringBuffer bf = StringBuffer();

    bf.write('try to request loading ${state.isLoading} at ${state.page + 1}');
    if (state.isLoading) {
      bf.write(' fail');
      return;
    }
    bf.write(' success');
    print(bf.toString());
    state = state.copyWith(
        isLoading: true, isLoadMoreDone: false, isLoadMoreError: false);

    final posts = await getPosts(state.page + 1);

    if (posts == null) {
      // error
      state = state.copyWith(isLoadMoreError: true, isLoading: false);
      return;
    }

    print('load more ${posts.length} posts at page ${state.page + 1}');
    if (posts.isNotEmpty) {
      // if load more return a list not empty, => increment page
      state = state.copyWith(
          page: state.page + 1,
          isLoading: false,
          isLoadMoreDone: posts.isEmpty,
          posts: [...state.posts, ...posts]);
    } else {
      // not increment page
      state = state.copyWith(
        isLoading: false,
        isLoadMoreDone: posts.isEmpty,
      );
    }
  }

  Future<void> refresh() async {
    _initPosts(1);
  }
}
