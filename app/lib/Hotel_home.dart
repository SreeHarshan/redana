import 'package:Redana/global.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as HTTP;

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
  String temp = "hello";

  //For order receive and notif
  late FirebaseMessaging messaging;

  // Orders in a list
  late Future<List<Hotel_order>> orders;

  @override
  void initState() {
    super.initState();

    initFCM();

    // initial call
    orders = refresh_orders();
  }

  Future<List<Hotel_order>> refresh_orders() async {
    String api = "/hotelorders?hotel_name=${widget.hotel_name}";
    List<Hotel_order> tempList = [];
    try {
      var uri = Uri.parse(server_address + api);
      var response = await HTTP.get(uri);
      if (response.statusCode == 200) {
        var jsonReponse =
            convert.jsonDecode(response.body) as Map<String, dynamic>;
        jsonReponse.forEach((key, value) {
          tempList.add(Hotel_order.fromJson(value));
        });
      }
    } catch (err) {
      print(err);
    }

    return tempList;
  }

  Future<void> initFCM() async {
    messaging = FirebaseMessaging.instance;

    print("init firebase");
    // Get permission
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();

    print("notif firebase");
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      setState(() {
        temp += "authorized";
      });
      print("authorized");
    } else {
      setState(() {
        temp += "not authorized";
      });
      print("Not authorized");
    }

    // add token for handshake
    String? token = await messaging.getToken(
        vapidKey:
            "BKeCnnkcuQCGxvtC7q5Q8j2nfEvcnGlCQ6jWYK_wNq9Y2cxRPfWt3JBaP2gTgD3k9tASSR9NUaYHSTyYNw7bL8A");

    messaging.getToken().then((value) {
      print(value);
    });

    await FirebaseMessaging.instance.subscribeToTopic('order');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data["hotel_name"] == widget.hotel_name) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Center(child: Text('Received a new order')),
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

        // Refresh the orders list to display the new order
        setState(() {
          orders = refresh_orders();
        });
      }
    });
  }

  void logout(context) {
    Navigator.pop(context);
    Navigator.pop(context);
  }

  // ignore: non_constant_identifier_names
  Widget Order_tile(BuildContext context, Hotel_order order) {
    return GestureDetector(
      onTap: () => {},
      child: Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          child: ListTile(
            title: Text(order.user_name),
            subtitle: Text(order.order_items.keys.join(" | ")),
//            leading: Icon(order.completed ? Icons.fork_right : Icons.fork_left),
          )),
    );
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
          drawer: Drawer(
              child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                  accountName: Text(widget.hotel_name),
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
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
              child: RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      orders = refresh_orders();
                    });
                  },
                  child: FutureBuilder(
                    future: orders,
                    builder: ((BuildContext context,
                        AsyncSnapshot<List<Hotel_order>> snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(
                            child: Text('Something went wrong :/'));
                      }
                      if (snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text("You have no orders"),
                        );
                      }
                      // If the data has arrived display it
                      return ListView.builder(
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: snapshot.data?.length,
                          itemBuilder: (context, index) {
                            return Order_tile(context, snapshot.data![index]);
                          });
                    }),
                  ))),
        ));
  }
}

class Hotel_order {
  String user_name;
  Map<String, dynamic> order_items;
  int total;
  bool completed;

  Hotel_order(this.user_name, this.order_items, this.total, this.completed);

  factory Hotel_order.fromJson(Map<String, dynamic> json) {
    return Hotel_order(json["user_name"], json["order_items"], json["total"],
        json["completed"]);
  }
}
