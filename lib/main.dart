import 'package:flutter/material.dart';
import 'package:flutter_loadmore_search/post.dart';
import 'package:flutter_loadmore_search/post_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      // print('pixel is ${_controller.position.pixels}');
      // print('max is ${_controller.position.maxScrollExtent}');
      if (_controller.position.pixels >
          _controller.position.maxScrollExtent * 0.8) {
        context.read(postsProvider).loadMorePost();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          decoration: InputDecoration(hintText: 'search'),
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

          // trường hợp init data hoặc lỗi
          if (posts == null) {
            // trường hợp lỗi
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
                  // phần tử cuối cùng (là progress, error hoặc không là gì nếu load more đã hết)
                  if (index == posts.length) {
                    // trường hợp load more lỗi thì hiện cái này
                    if (isLoadMoreError) {
                      return Center(
                        child: Text('Error'),
                      );
                    }
                    // trường hợp load more nhưng không còn ptu nào
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
