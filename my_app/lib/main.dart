import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_app/storage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.deepPurple,
      ),
      home: const MyHomePage(title: 'CINS 467 Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final UserStorage _storage = UserStorage();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<int> _counter;
  late Future<String> _username;
  late Future<bool> _metric;
  late Future<int> _age;
  //String _username = 'none';
  //int _counter = 0;

  Future<void> _incrementCounter() async {
    final SharedPreferences prefs = await _prefs;
    final int counter = (prefs.getInt('counter') ?? 0) + 1;
    setState(() {
      _counter = prefs.setInt('counter', counter).then((bool success) {
        return counter;
      });
    });
  }

  Future<void> _decrementCounter() async {
    final SharedPreferences prefs = await _prefs;
    final int counter = (prefs.getInt('counter') ?? 0) - 1;
    setState(() {
      _counter = prefs.setInt('counter', counter).then((bool success) {
        return counter;
      });
    });
  }

  Future<void> _setUserInfo() async {
    _storage.readUserInfo().then((value) async {
      final String username = (value == 'Shelley' ? 'swong' : 'Shelley');
      _storage.readUserMetric().then((metric) async {
        _storage.readUserAge().then((age) async {
          await _storage.writeUserInfo(username, metric, age);
          setState(() {
            _username = _storage.readUserInfo();
          });
        });
      });
    });
  }

  Future<void> _setUserMetric() async {
    _storage.readUserMetric().then((value) async {
      final bool metric = (value ? false : true);
      _storage.readUserInfo().then((name){
        _storage.readUserAge().then((age){
          _storage.writeUserInfo(name, metric, age);
          setState(() {
            _metric = _storage.readUserMetric();
          });
        });
      });
    });
  }

  Future<void> _setUserAge() async {
    _storage.readUserAge().then((value) async {
      final int age = (value == 42 ? 41 : 42);
      _storage.readUserInfo().then((name){
        _storage.readUserMetric().then((metric){
          _storage.writeUserInfo(name, metric, age);
          setState(() {
            _age = _storage.readUserAge();
          });
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _counter = _prefs.then((SharedPreferences prefs) {
      return prefs.getInt('counter') ?? 0;
    });
    _username = _storage.readUserInfo();
    _metric = _storage.readUserMetric();
    _age = _storage.readUserAge();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder(
              future: _username,
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const CircularProgressIndicator();
                  default:
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return Container(
                        padding:
                            const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 0.0),
                        child: Text(
                          'Hello ${snapshot.data}!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      );
                    }
                }
              },
            ),
            FutureBuilder(
              future: _metric,
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const CircularProgressIndicator();
                  default:
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return Container(
                        padding:
                            const EdgeInsets.all(8.0),
                        child: Text(
                          'Use metric? ${snapshot.data}!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      );
                    }
                }
              },
            ),
            ElevatedButton(
              onPressed: _setUserMetric, 
              child: const Text('Metric/Imperial'),
            ),
            FutureBuilder(
              future: _age,
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const CircularProgressIndicator();
                  default:
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return Container(
                        padding:
                            const EdgeInsets.all(8.0),
                        child: Text(
                          'Age: ${snapshot.data}!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      );
                    }
                }
              },
            ),
            ElevatedButton(
              onPressed: _setUserAge, 
              child: const Text('Toggle Age'),
            ),
            const Text(
              'You have clicked the button this many times:',
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Tooltip(
                    message: 'increments counter',
                    child: ElevatedButton(
                      onPressed: _incrementCounter,
                      child: const Icon(Icons.thumb_up),
                    ),
                  ),
                  FutureBuilder(
                    future: _counter,
                    builder:
                        (BuildContext context, AsyncSnapshot<int> snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return const CircularProgressIndicator();
                        default:
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return Container(
                              padding: const EdgeInsets.fromLTRB(
                                  12.0, 0.0, 12.0, 0.0),
                              child: Text(
                                'Counter: ${snapshot.data}',
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                            );
                          }
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.thumb_down),
                    tooltip: 'decrements counter',
                    color: Theme.of(context).primaryColor,
                    onPressed: _decrementCounter,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _setUserInfo,
        tooltip: 'Toggle user information',
        child: const Icon(Icons.person),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
