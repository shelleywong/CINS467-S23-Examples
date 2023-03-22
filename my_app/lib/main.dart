import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

import 'home.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (kIsWeb) {
    runApp(const MyApp(myAppTitle: 'Web CINS467'));
  } else if (Platform.isAndroid) {
    runApp(const MyApp(myAppTitle: 'Android CINS467'));
  } else {
    runApp(const MyApp(myAppTitle: 'CINS467'));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.myAppTitle});

  final String myAppTitle;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var providers = [EmailAuthProvider()];

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      //home: MyHomePage(title: '$myAppTitle Home Page'),
      initialRoute:
          FirebaseAuth.instance.currentUser == null ? '/sign-in' : '/',
      routes: {
        '/': (context) => MyHomePage(title: '$myAppTitle Home Page'),
        '/sign-in': (context) {
          return SignInScreen(
            providers: providers,
            actions: [
              AuthStateChangeAction<SignedIn>((context, state) {
                // if (!state.user!.emailVerified) {
                //   Navigator.pushNamed(context, '/verify-email');
                // } else {
                //   Navigator.pushReplacementNamed(context, '/');
                // }
                Navigator.pushReplacementNamed(context, '/');
              }),
            ],
          );
        },
        '/verify-email': (context) {
          return EmailVerificationScreen(
            actions: [
              EmailVerifiedAction(() {
                Navigator.pushReplacementNamed(context, '/sign-in');
              }),
              AuthCancelledAction((context) {
                FirebaseUIAuth.signOut(context: context);
                Navigator.pushReplacementNamed(context, '/sign-in');
              }),
            ],
          );
        },
        '/profile': (context) {
          return ProfileScreen(
            appBar: AppBar(
              title: const Text('User Profile'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.home),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/');
                  },
                )
              ],
            ),
            providers: providers,
            actions: [
              SignedOutAction((context) {
                Navigator.pushReplacementNamed(context, '/sign-in');
              }),
            ],
          );
        },
      },
    );
  }
}
