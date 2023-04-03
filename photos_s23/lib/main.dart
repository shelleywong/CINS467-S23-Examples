import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'add_photos.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: getBody(), 
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPhotos(title: 'Add a photo'),
            ),
          );
        },
        tooltip: 'Add a photo',
        child: const Icon(Icons.photo_camera),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  List<Widget> getBody() {
    return <Widget>[
      // const Text(
      //   'CINS467',
      // ),
      StreamBuilder(
        stream: FirebaseFirestore.instance.collection('photos').snapshots(),
        builder:(context, snapshot) {
          switch(snapshot.connectionState){
            case ConnectionState.waiting:
              return const CircularProgressIndicator();
            default:
              if(snapshot.hasError){
                return Text('Error: ${snapshot.error}');
              } else {
                return Expanded(
                  child: Scrollbar(
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder:(context, index) {
                        return photoWidget(snapshot, index);
                      },
                    )
                  ),
                );
              }
          }
        },
      ),
    ];
  }

  Widget photoWidget(AsyncSnapshot<QuerySnapshot> snapshot, int index){
    try{
      return Card(
        margin: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(snapshot.data!.docs[index]['title']),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.network(snapshot.data!.docs[index]['downloadURL']),
            ),
          ],
        ),
      );
    } catch(e){
      return Text('Error: $e');
    }
  }
}
