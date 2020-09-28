// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:flutter_loadmore_search/post.dart';
import 'package:flutter_loadmore_search/post_provider.dart';

final keyProvider = StateProvider<String>((ref) {
  return '';
});

final postSearchProvider = StateProvider<List<Post>>((ref) {
  final postState = ref.watch(postsProvider.state);
  final key = ref.watch(keyProvider).state;

  return postState.posts
      ?.where((element) =>
          element.body.contains(key) || element.title.contains(key))
      ?.toList();
});

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ScrollController _controller = ScrollController();
  int oldLength = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() async {
      // print('pixel is ${_controller.position.pixels}');
      // print('max is ${_controller.position.maxScrollExtent}');
      if (_controller.position.pixels >
          _controller.position.maxScrollExtent -
              MediaQuery.of(context).size.height) {
        if (oldLength == context.read(postsProvider.state).posts.length) {
          // make sure ListView has newest data after previous loadMore
          context.read(postsProvider).loadMorePost();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          decoration: InputDecoration(
              hintText: 'Enter to search!',
              hintStyle: TextStyle(color: Colors.yellow)),
          onChanged: (newValue) {
            context.read(keyProvider).state = newValue;
          },
        ),
      ),
      body: Consumer(
        builder: (ctx, watch, child) {
          final isLoadMoreError = watch(postsProvider.state).isLoadMoreError;
          final isLoadMoreDone = watch(postsProvider.state).isLoadMoreDone;
          final isLoading = watch(postsProvider.state).isLoading;
          final posts = watch(postSearchProvider).state;

          // sync oldLength with post.length to make sure ListView has newest
          // data, so loadMore will work correctly
          oldLength = posts?.length ?? 0;
          // init data or error
          if (posts == null) {
            // error case
            if (isLoading == false) {
              return Center(
                child: Text('error'),
              );
            }
            return const _Loading();
          }
          return RefreshIndicator(
            onRefresh: () {
              return context.read(postsProvider).refresh();
            },
            child: ListView.builder(
                controller: _controller,
                itemCount: posts.length + 1,
                itemBuilder: (ctx, index) {
                  // last element (progress bar, error or 'Done!' if reached to the last element)
                  if (index == posts.length) {
                    // load more and get error
                    if (isLoadMoreError) {
                      return Center(
                        child: Text('Error'),
                      );
                    }
                    // load more but reached to the last element
                    if (isLoadMoreDone) {
                      return Center(
                        child: Text('Done!'),
                      );
                    }
                    return LinearProgressIndicator();
                  }
                  return ListTile(
                    title: Text(posts[index].title),
                    subtitle: Text(posts[index].body),
                    trailing: Text(posts[index].id.toString()),
                  );
                }),
          );
        },
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}
