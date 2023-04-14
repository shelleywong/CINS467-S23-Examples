import 'package:flutter/material.dart';

import 'package:nav_stack/first.dart';
import 'package:nav_stack/second.dart';

Widget getDrawer(BuildContext context) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Text('Drawer Header'),
        ),
        ListTile(
          leading: const Icon(Icons.arrow_back),
          title: const Text('Go back'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('Push first route'),
          onTap: () {
            Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const FirstRoute(),
              ),
            );
          },
        ),
        ListTile(
          title: const Text('Push second and remove all'),
          onTap: () {
            Navigator.pushAndRemoveUntil<void>(
              context,
              MaterialPageRoute<void>(builder: (BuildContext context) => const SecondRoute()),
              (Route<dynamic> route) => false,
            );
          }
        )
      ],
    ),
  );
}
