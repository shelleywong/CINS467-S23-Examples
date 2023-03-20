import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import 'firebase_options.dart';
import 'package:my_app/storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if(kIsWeb){
    runApp(const MyApp(myAppTitle: 'Web CINS467'));
  } else if(Platform.isAndroid){
    runApp(const MyApp(myAppTitle: 'Android CINS467'));
  } else{
    runApp(const MyApp(myAppTitle: 'CINS467'));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.myAppTitle});

  final String myAppTitle;

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
      home: MyHomePage(title: '$myAppTitle Home Page'),
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
  late Future<Position> _position;
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );
  late StreamSubscription<Position> positionStream;

  File? _image;

  Future<void> _getImages() async {
    final ImagePicker picker = ImagePicker();
    // Capture a photo
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if(photo != null){
        _image = File(photo.path); 
      } else {
        if (kDebugMode) {
          print('No photo captured');
        }
      }
      
    });
  }

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

  Future<void> _setUsername() async {
    _storage.readUsername().then((value) async {
      final String username = (value == 'Shelley' ? 'swong' : 'Shelley');
      _storage.readUserMetric().then((metric) async {
        _storage.readUserAge().then((age) async {
          await _storage.writeUserInfo(username, metric, age);
        });
      });
    });
  }

  Future<void> _setUserMetric() async {
    _storage.readUserMetric().then((value) async {
      final bool metric = (value ? false : true);
      _storage.readUsername().then((name) {
        _storage.readUserAge().then((age) {
          _storage.writeUserInfo(name, metric, age);
        });
      });
    });
  }

  Future<void> _setUserAge() async {
    _storage.readUserAge().then((value) async {
      final int age = (value == 42 ? 41 : 42);
      _storage.readUsername().then((name) {
        _storage.readUserMetric().then((metric) {
          _storage.writeUserInfo(name, metric, age);
        });
      });
    });
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  /// Ref: https://pub.dev/packages/geolocator
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  @override
  void initState() {
    super.initState();
    _counter = _prefs.then((SharedPreferences prefs) {
      return prefs.getInt('counter') ?? 0;
    });
    _position = _determinePosition();
    positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
    (Position? position) {
        // handle the position
        if (kDebugMode) {
          print(position == null ? 'Unknown' : '${position.latitude.toString()}, ${position.longitude.toString()}');
        }
    });
  }

  @override
  void dispose() {
    positionStream.cancel();
    super.dispose();
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
            Expanded(
              flex: 2,
              child: _image == null
                ? const Icon(Icons.landscape, size: 100)
                : Image.file(_image!, height: 200),
            ),
            Expanded(
              flex: 1,
              child: Tooltip(
                message: 'Launch the camera',
                child: ElevatedButton(
                  onPressed: _getImages,
                  child: const Icon(Icons.photo_camera),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: FutureBuilder(
                future: _position,
                builder: (context, snapshot){
                  switch(snapshot.connectionState){
                    case(ConnectionState.waiting):
                      return const CircularProgressIndicator();
                    default:
                      if(snapshot.hasError){
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return Text(
                          '${snapshot.data!.latitude}, ${snapshot.data!.longitude} -- ${snapshot.data!.accuracy}',
                        );
                      }
                  }
                },
              ),
            ),
            Expanded(
              flex: 2,
              child: StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case (ConnectionState.waiting):
                      return const CircularProgressIndicator();
                    default:
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData) {
                        return Container();
                      } else {
                        return Column(
                          children: [
                            Text('${snapshot.data!.size}'),
                            Text('${snapshot.data!.docs[1]["name"]}'),
                            Text('${snapshot.data!.docs[1]["metric"]}'),
                            Text('${snapshot.data!.docs[1]["age"]}'),
                          ],
                        );
                      }
                  }
                },
              ),
            ),
            // FutureBuilder(
            //   future: _username,
            //   builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            //     switch (snapshot.connectionState) {
            //       case ConnectionState.waiting:
            //         return const CircularProgressIndicator();
            //       default:
            //         if (snapshot.hasError) {
            //           return Text('Error: ${snapshot.error}');
            //         } else {
            //           return Container(
            //             padding:
            //                 const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 0.0),
            //             child: Text(
            //               'Hello ${snapshot.data}!',
            //               textAlign: TextAlign.center,
            //               style: Theme.of(context).textTheme.headlineMedium,
            //             ),
            //           );
            //         }
            //     }
            //   },
            // ),
            // FutureBuilder(
            //   future: _metric,
            //   builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            //     switch (snapshot.connectionState) {
            //       case ConnectionState.waiting:
            //         return const CircularProgressIndicator();
            //       default:
            //         if (snapshot.hasError) {
            //           return Text('Error: ${snapshot.error}');
            //         } else {
            //           return Container(
            //             padding:
            //                 const EdgeInsets.all(8.0),
            //             child: Text(
            //               'Use metric? ${snapshot.data}!',
            //               textAlign: TextAlign.center,
            //               style: Theme.of(context).textTheme.headlineMedium,
            //             ),
            //           );
            //         }
            //     }
            //   },
            // ),
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: _setUserMetric,
                child: const Text('Metric/Imperial'),
              ),
            ),
            // FutureBuilder(
            //   future: _age,
            //   builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
            //     switch (snapshot.connectionState) {
            //       case ConnectionState.waiting:
            //         return const CircularProgressIndicator();
            //       default:
            //         if (snapshot.hasError) {
            //           return Text('Error: ${snapshot.error}');
            //         } else {
            //           return Container(
            //             padding:
            //                 const EdgeInsets.all(8.0),
            //             child: Text(
            //               'Age: ${snapshot.data}!',
            //               textAlign: TextAlign.center,
            //               style: Theme.of(context).textTheme.headlineMedium,
            //             ),
            //           );
            //         }
            //     }
            //   },
            // ),
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: _setUserAge,
                child: const Text('Toggle Age'),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
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
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _setUsername,
        tooltip: 'Toggle user information',
        child: const Icon(Icons.person),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
