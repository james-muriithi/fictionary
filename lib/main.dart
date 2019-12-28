import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Fictionary'),
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
  String _url = 'https://owlbot.info/api/v4/dictionary/';
  String _token = 'cb3b899a930da2bfc64c545098a5f98e5b82f78e';
  TextEditingController _controller = TextEditingController();

  StreamController _streamController;
  Stream _stream;

  _search() async {
    if (_controller.text == null || _controller.text.length == 0) {
      _streamController.add(null);
    }

    Response response = await get(_url + _controller.text.trim(),
        headers: {'Authorization': "Token " + _token});

    _streamController.add(json.decode(response.body));
  }

  @override
  void initState() {
    super.initState();
    _streamController = StreamController();
    _stream = _streamController.stream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 12.0, bottom: 8.0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.0)),
                  child: TextFormField(
                    onChanged: (String text) {},
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Search for a word',
                      contentPadding: const EdgeInsets.only(left: 24.0),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  _search();
                },
              )
            ],
          ),
        ),
      ),
      body: StreamBuilder(
        stream: _stream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return Center(
              child: Text("Enter a search word"),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data['definitions'].length,
            itemBuilder: (BuildContext ctx, int index) {
              return ListBody(
                children: <Widget>[
                  Card(
                    elevation: 5,
                    color: Colors.grey[300],
                    child: ListTile(
                        leading: snapshot.data['definitions'][index]
                                    ['image_url'] ==
                                null
                            ? null
                            : CircleAvatar(
                                backgroundImage: NetworkImage(snapshot
                                    .data['definitions'][index]['image_url']),
                              ),
                        title: Text(
                          _controller.text.trim() +
                              "(" +
                              snapshot.data['definitions'][index]['type'] +
                              ")",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 10.0, bottom: 5.0),
                              child: Text(snapshot.data['definitions'][index]
                                  ['definition']),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5.0),
                              child: Text("Example: " +
                                  snapshot.data['definitions'][index]
                                      ['example']),
                            ),
                          ],
                        )),
                  )
                ],
              );
            },
          );
        },
      ),
    );
  }
}
