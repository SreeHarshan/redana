// ignore: file_names
import 'package:flutter/material.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _userhome createState() => _userhome();
}

// ignore: camel_case_types
class _userhome extends State<UserHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Redana",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
            onPressed: () => {},
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
            )),
        backgroundColor: Colors.red,
        actions: <Widget>[
          IconButton(
              onPressed: () => {Navigator.pop(context)},
              icon: const Icon(
                Icons.exit_to_app,
                color: Colors.white,
              ))
        ],
      ),
    );
  }
}
