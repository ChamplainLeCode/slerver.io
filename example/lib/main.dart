import 'package:flutter/material.dart';
import 'package:slerver_io/slerver_io.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SlerverIO client;

  @override
  void initState() {
    super.initState();
    initClient();
  }

  initClient() async {
    client = await SlerverIO.connect('10.42.0.241', 9000, autoReconnect: true);
    var io = client.router;
    io
      ..on('/name', (Map<String, dynamic> params) {
        print(params['message']);
      })
      ..on('/surname', (List params) {
        print('${params.first} => ${params.last}');
      })
      ..on('connect', () {
        print('Connected successfully');
      });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(''),
        ),
        body: Center(
          child: Column(
            children: [
              FlatButton(onPressed: writeSomething, child: Text('Write'))
            ],
          ),
        ),
      ),
    );
  }

  writeSomething() {
    client
      ..send({
        'path': '/name',
        'params': {'name': 'Bakop', 'surname': 'Champlain'}
      })
      ..send({
        'path': '/surname',
        'params': ['Sandjong', 'Nana', 'Cabrel', 'Jordan']
      })
      ..send({
        'path': '/name',
        'params': {'name': 'Bakop', 'surname': 'Champlain'}
      })
      ..send({
        'path': '/surname',
        'params': ['Sandjong', 'Nana', 'Cabrel', 'Jordan']
      })
      ..send({
        'path': '/name',
        'params': {'name': 'Bakop', 'surname': 'Champlain'}
      })
      ..send({
        'path': '/surname',
        'params': ['Sandjong', 'Nana', 'Cabrel', 'Jordan']
      })
      ..send({
        'path': '/name',
        'params': {'name': 'Bakop', 'surname': 'Champlain'}
      })
      ..send({
        'path': '/surname',
        'params': ['Sandjong', 'Nana', 'Cabrel', 'Jordan']
      })
      ..send({
        'path': '/name',
        'params': {'name': 'Bakop', 'surname': 'Champlain'}
      })
      ..send({
        'path': '/surname',
        'params': ['Sandjong', 'Nana', 'Cabrel', 'Jordan']
      });
  }
}
