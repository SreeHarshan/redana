import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ignore: camel_case_types
class Hotel_home extends StatefulWidget {
  String hotel_name, hotel_email;
  Hotel_home(this.hotel_name, this.hotel_email, {super.key});

  @override
  // ignore: library_private_types_in_public_api
  _hotel_home createState() => _hotel_home();
}

// ignore: camel_case_types
class _hotel_home extends State<Hotel_home> {
  //For scaffold drawer check
  final scaffoldKey = GlobalKey<ScaffoldState>();

  void logout(context) {
    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!scaffoldKey.currentState!.isDrawerOpen) {
          SystemNavigator.pop(animated: true);
        }
        // If drawer is open then close it
        scaffoldKey.currentState!.closeDrawer();
        return false;
      },
      child: Scaffold(
        key: scaffoldKey,
        drawer: Drawer(
            child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
                accountName: Text(widget.hotel_name!),
                accountEmail: Text(widget.hotel_email)),
            ListTile(
              title: const Text("Settings"),
              trailing: const Icon(Icons.arrow_right),
              leading: const Icon(Icons.settings),
              onTap: () {},
            ),
            ListTile(
              title: const Text("Logout"),
              leading: const Icon(Icons.exit_to_app),
              onTap: () => {logout(context)},
            ),
          ],
        )),
        appBar: AppBar(
          title: const Text(
            "Redana",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          leading: Builder(
            builder: (context) {
              return IconButton(
                  onPressed: () => {Scaffold.of(context).openDrawer()},
                  icon: const Icon(
                    Icons.menu,
                    color: Colors.white,
                  ));
            },
          ),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
          child: FutureBuilder(builder: ((context, snapshot) {
            return Text("");
          })),
        ),
      ),
    );
  }
}
