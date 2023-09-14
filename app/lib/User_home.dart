// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as HTTP;
import 'dart:convert' as convert;
import 'package:google_sign_in/google_sign_in.dart';

import 'Hotel.dart';
import 'Schema.dart';
import 'global.dart';

// ignore: must_be_immutable
class UserHome extends StatefulWidget {
  GoogleSignInAccount useraccount;
  UserHome(this.useraccount, {super.key});

  @override
  // ignore: library_private_types_in_public_api
  _userhome createState() => _userhome();
}

// ignore: camel_case_types
class _userhome extends State<UserHome> {
  late Future<List<Hotel>> hotels;
  List<HotelCard> hotels_card = [];

  //For scaffold drawer check
  final scaffoldKey = GlobalKey<ScaffoldState>();

  Future<List<Hotel>> get_hotels() async {
    //get hotels from server
    String api = '/hotels';
    var url = Uri.parse(server_address + api);
    List<Hotel> _hotels = [];
    try {
      var response = await HTTP.get(url).whenComplete(() {});
      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body) as List<dynamic>;
        for (var element in jsonResponse) {
          _hotels.add(Hotel(element));
        }
      }
    } on Exception catch (e) {
      print(e);
      throw Exception(e);
    }

    //Convert hotels to cards
    for (var hotel in _hotels) {
      hotels_card.add(HotelCard(
          widget.useraccount.email, widget.useraccount.displayName, hotel));
    }

    print("completed fetching hotels");

    return _hotels;
  }

  @override
  void initState() {
    super.initState();

    hotels = get_hotels();
  }

  Future<void> logout(context) async {
    await GoogleSignIn().signOut();

    //Successfully logged out
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Center(child: Text('Logged out')),
        duration: const Duration(milliseconds: 1500),
        width: 180.0,
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 5.0,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );

    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if (!scaffoldKey.currentState!.isDrawerOpen) {
            showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                      title: const Text("Warning"),
                      content:
                          const Text("Are you sure you want to close the app?"),
                      actions: <Widget>[
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Cancel"),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            SystemNavigator.pop(animated: true);
                          },
                          child: const Text("Ok"),
                        )
                      ],
                    ));
          }
          // If drawer is open then close it
          scaffoldKey.currentState!.closeDrawer();
          return false;
        },
        child: Scaffold(
          key: scaffoldKey,
          // Menu drawer
          drawer: Drawer(
              child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                  currentAccountPicture:
                      Image.network(widget.useraccount.photoUrl!),
                  accountName: Text(widget.useraccount.displayName!),
                  accountEmail: Text(widget.useraccount.email)),
              ListTile(
                title: const Text("Your Orders"),
                trailing: const Icon(Icons.arrow_right),
                leading: const Icon(Icons.shopping_basket),
                onTap: () {},
              ),
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
          body: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
            child: Column(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(left: 15),
                  child: const Text(
                    "Hotels nearby",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),

                // FutureBuilder to load the hotel details
                FutureBuilder(
                    future: hotels,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(
                            child: Text('Something went wrong :('));
                      }
                      // If the data has arrived display it
                      return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: hotels_card.length,
                          itemBuilder: (context, index) {
                            return hotels_card[index];
                          });
                    }),
              ],
            ),
          ),
        ));
  }
}

// ignore: camel_case_types
class User_orders extends StatefulWidget {
  const User_orders({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _user_orders createState() => _user_orders();
}

// ignore: camel_case_types
class _user_orders extends State<User_orders> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Orders"),
      ),
    );
  }
}
