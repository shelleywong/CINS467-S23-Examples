import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _myController = TextEditingController();
  String? _inputText = '';

  void _submitForm() {
    if(_formKey.currentState!.validate()){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Data processing...'),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {
              _formKey.currentState!.save();
              _myController.clear();
            },
          ),
        ),
      );
      if (kDebugMode) {
        print('Text field input: ${_myController.text}');
      }
    }

  }

  void _saveText(String? value){
    setState(() {
      _inputText = value;
    });
  }

  String? _textValidator(String? value) {
    if(value == null || value.isEmpty){
      return 'Please enter something for your name';
    } else if(value.contains(';')){
      return 'Do not use the ";" char.';
    } else if(value.length < 2){
      return 'Must be at least 2 characters';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _myController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.person),
                  hintText: 'What do people call you?',
                  labelText: 'Name *',
                ),
                onSaved: _saveText,
                validator: _textValidator,
              ),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _inputText ?? '',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
