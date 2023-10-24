// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as HTTP;
import 'dart:convert' as convert;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:carousel_slider/carousel_slider.dart';

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
  Future<List<Hotel>>? hotels;

  //For scaffold drawer check
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Bottom nav
  int _navindex = 0;

  // Cart
  late Cart_obj cart;

  // carousal
  int _current = 0;
  final CarouselController _controller = CarouselController();
  // ignore: non_constant_identifier_names
  late Future<List<String>> carousal_items;

  // ignore: non_constant_identifier_names
  Future<List<Hotel>> get_hotels() async {
    //get hotels from server
    String api2 = '/hotels';
    var url2 = Uri.parse(server_address + api2);
    print("getting hotels");
    print(server_address + api2);
    List<Hotel> _hotels = [];
    try {
      var response2 = await HTTP.get(url2);
      if (response2.statusCode == 200) {
        var jsonResponse2 = convert.jsonDecode(response2.body) as List<dynamic>;
        for (var element in jsonResponse2) {
          _hotels.add(
              Hotel(element['name'], element['address'], element['ph_no']));
        }
      } else {
        print(response2.statusCode);
      }
    } on Exception catch (e) {
      print(e);
      throw Exception(e);
    }

    setState(() {});

    return _hotels;
  }

  // ignore: non_constant_identifier_names
  Future<List<String>> _get_carousal_items() async {
    String api = "/offers";
    var url = Uri.parse(server_address + api);
    List<String> _items = [];
    try {
      var response = await HTTP.get(url);
      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body);

        for (var el in jsonResponse) {
          _items.add(el);
        }
      } else {
        print(response.statusCode);
      }
    } on Exception catch (e) {
      print(e);
      throw Exception(e);
    }
    return _items;
  }

  @override
  void initState() {
    super.initState();

    hotels = get_hotels();
    carousal_items = _get_carousal_items();

    cart = Cart_obj(widget.useraccount.displayName, widget.useraccount.email);
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

  void _onNavItemTap(int index) {
    setState(() {
      _navindex = index;
    });
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
              "WELCOME",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color.fromARGB(255, 255, 0, 0),
            leading: Builder(
              builder: (context) {
                return IconButton(
                  onPressed: () => {Scaffold.of(context).openDrawer()},
                  icon: Image.asset("assets/Redana_logo.jpeg"),
                );
              },
            ),
          ),
          body: Column(children: [
            // Carousal
            FutureBuilder(
                future: carousal_items,
                builder: (context, AsyncSnapshot<List<String>> snapshot) {
                  print(snapshot.data);
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    return Column(children: <Widget>[
                      // Actual Slider
                      CarouselSlider(
                        options: CarouselOptions(
                            autoPlay: true,
                            enlargeCenterPage: true,
                            aspectRatio: 2.0,
                            onPageChanged: (index, reason) {
                              setState(() {
                                _current = index;
                              });
                            }),
                        items: snapshot.data!.asMap().entries.map((i) {
                          return Builder(
                            builder: (BuildContext context) {
                              return GestureDetector(
                                  onTap: () {
                                    /*
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(//TODO add two future and get hotel from there
                                            builder: (context) => HotelPage(
                                                widget.useraccount.email,
                                                widget.useraccount.displayName,
                                                )));*/
                                  },
                                  child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 5.0, vertical: 10.0),
                                      child: Image.network(
                                          "$server_address/offerimg?offer=${i.key + 1}")));
                            },
                          );
                        }).toList(),
                      ),
                      // Dots to indicate and navigate
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: snapshot.data!.asMap().entries.map((entry) {
                          return GestureDetector(
                            onTap: () => _controller.animateToPage(entry.key),
                            child: Container(
                              width: 12.0,
                              height: 12.0,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 4.0),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black)
                                      .withOpacity(
                                          _current == entry.key ? 0.9 : 0.4)),
                            ),
                          );
                        }).toList(),
                      ),
                    ]);
                  }
                  return const Text("Loading");
                }),
            const Row(children: <Widget>[
              Expanded(
                  child: Divider(
                color: Colors.red,
                height: 5,
                thickness: 3.0,
              )),
              SizedBox(width: 2),
              Text(
                "Select your Hotel",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
              ),
              SizedBox(width: 2),
              Expanded(
                  child: Divider(
                color: Colors.red,
                height: 5,
                thickness: 3.0,
              )),
            ]),
            SingleChildScrollView(
              padding: const EdgeInsets.only(top: 20.0, left: 5.0, right: 5.0),
              child: Column(
                children: <Widget>[
                  // FutureBuilder to load the hotel details
                  FutureBuilder(
                      future: hotels,
                      builder: (context, AsyncSnapshot<List<Hotel>> snapshot) {
                        if (snapshot.connectionState != ConnectionState.done ||
                            !snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return const Center(
                              child: Text('Something went wrong :('));
                        }
                        // If the data has arrived display it
                        return GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // number of items in each row
                              mainAxisSpacing: 10.0, // spacing between rows
                              crossAxisSpacing: 10.0, // spacing between columns
                            ),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data?.length,
                            itemBuilder: (context, index) {
                              return HotelCard(
                                  widget.useraccount.email,
                                  widget.useraccount.displayName,
                                  snapshot.data![index]);
                            });
                      }),
                ],
              ),
            ),
          ]),
          /*
          bottomNavigationBar: BottomNavigationBar(
              currentIndex: _navindex,
              onTap: _onNavItemTap,
              unselectedItemColor: Colors.grey,
              selectedItemColor: Colors.black,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.account_circle), label: "Account"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.trolley), label: "Cart"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.settings), label: "Settings"),
              ]),*/
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
