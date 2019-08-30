import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:github_search/blocs/search_bloc.dart';
import 'package:github_search/details/details_page.dart';
import 'package:github_search/models/search_item.dart';
import 'package:github_search/services/github_api.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
  ScrollController _scrollController;
  SearchBloc _searchBloc;

  @override
  void initState() {
    _searchBloc = new SearchBloc(GithubApi());
    _scrollController = new ScrollController();
    _scrollController.addListener(pagesListener);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(pagesListener)
      ..dispose();
    _searchBloc.dispose();

    super.dispose();
  }

  void pagesListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 3) {
      _searchBloc.pageEvent.add(null);
    }
  }

  Widget _textField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        onChanged: _searchBloc.queryEvent.add,
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Digite o nome do repositório",
            labelText: "Pesquisa"),
      ),
    );
  }

  Widget _items(SearchItem item) {
    print("teste");

    return ListTile(
      leading: Hero(
        tag: item.url,
        child: CircleAvatar(
          backgroundImage: NetworkImage(item?.avatarUrl),
        ),
      ),
      title: Text(item?.fullName ?? "title"),
      subtitle: Text(item?.url ?? "url"),
      onTap: () => Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => DetailsWidget(
                    item: item,
                  ))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Github Search"),
      ),
      body: Column(
        children: <Widget>[
          _textField(),
          StreamBuilder<List<SearchItem>>(
            stream: _searchBloc.items,
            builder: (BuildContext context,
                AsyncSnapshot<List<SearchItem>> snapshot) {
              return Expanded(
                child: snapshot.hasData
                    ? ListView.builder(
                        controller: _scrollController,
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          return _items(snapshot.data[index]);
                        },
                      )
                    : Center(
                        child: CircularProgressIndicator(),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
}
