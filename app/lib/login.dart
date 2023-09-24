import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as HTTP;
import 'dart:convert' as convert;

import 'User_home.dart';
import 'Hotel_home.dart';
import 'global.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  // handle google auth
  Future<void> signin(context) async {
    GoogleSignInAccount? _useraccount;

    try {
      await GoogleSignIn().signIn().then((userdata) async {
        _useraccount = userdata!;

        String api =
            "/userlogin?name=${_useraccount?.displayName}&email=${_useraccount?.email}";

        var url = Uri.parse(server_address + api);
        var response = await HTTP.get(url).whenComplete(() => ());
        if (response.statusCode == 200) {
          var jsonResponse =
              convert.jsonDecode(response.body) as Map<String, dynamic>;
          print(jsonResponse);
          if (jsonResponse["Success"]) {
            go_to_home(context, _useraccount);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Center(
                  child: Text(
                'Unable to login ',
                style: TextStyle(color: Colors.red),
              )),
              duration: const Duration(milliseconds: 1500),
              width: 280.0,
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 5.0,
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ));
          }
        }
      });
    } catch (error) {
      print(error);
    }
  }

  // switches to the home page
  // ignore: non_constant_identifier_names
  void go_to_home(context, useraccount) {
    // Logged in snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        // ignore: prefer_interpolation_to_compose_strings
        content: Center(child: Text('Logged in as ' + useraccount.displayName)),
        duration: const Duration(milliseconds: 1500),
        width: 280.0,
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
    //switch to home page
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => UserHome(useraccount)));
  }

  @override
  Widget build(BuildContext context) {
    GoogleSignIn().isSignedIn().then(
      (value) {
        if (value) go_to_home(context, GoogleSignIn().currentUser);
      },
    );

    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Image.asset(
          // logo
          "assets/Redana_logo.jpeg",
          width: 200,
          height: 200,
        ),
        const SizedBox(height: 40),
        GestureDetector(
            //sign in button
            onTap: () => {signin(context)},
            child: Center(
              child: Container(
                margin: const EdgeInsets.only(top: 20),
                width: 250,
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(150),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Image.asset("assets/google_icon.png",
                        width: 48, height: 48),
                    const SizedBox(
                      width: 5.0,
                    ),
                    const Text(
                      'Sign-in with Google',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    )
                  ],
                ),
              ),
            )),
        GestureDetector(
            // hotel login button
            onTap: () => {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HotelLogin()))
                },
            child: Center(
              child: Container(
                margin: const EdgeInsets.only(top: 20),
                width: 250,
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(150),
                  color: Colors.red,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.restaurant,
                      color: Colors.white,
                      size: 30,
                    ),
                    SizedBox(
                      width: 5.0,
                    ),
                    Text(
                      'Hotel Login',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16),
                    )
                  ],
                ),
              ),
            ))
      ],
    ));
  }
}

class HotelLogin extends StatefulWidget {
  const HotelLogin({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _hotellogin createState() => _hotellogin();
}

// ignore: camel_case_types
class _hotellogin extends State<HotelLogin> {
  late TextEditingController _pwdcontroller, _emcontroller;
  late bool g_signin;
  bool _is_loading = false;

  @override
  void initState() {
    _pwdcontroller = TextEditingController();
    _emcontroller = TextEditingController();
    g_signin = false;
    super.initState();
  }

  // ignore: non_constant_identifier_names
  void _goto_hotel_home(String name, String email) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => Hotel_home(name, email)));
  }

  // login to hotelpage
  Future<void> login(context) async {
    print("Logging in");
    setState(() {
      _is_loading = true;
    });
    try {
      String api =
          "/hotellogin?email=${_emcontroller.text}&pass=${_pwdcontroller.text}";
      var url = Uri.parse(server_address + api);
      var response = await HTTP.get(url).whenComplete(() => ());
      if (response.statusCode == 200) {
        var jsonResponse =
            convert.jsonDecode(response.body) as Map<String, dynamic>;
        print(jsonResponse);
        if (jsonResponse["Success"]) {
          _goto_hotel_home(jsonResponse["name"], jsonResponse["email"]);
          setState(() {
            _is_loading = false;
          });
          _emcontroller.clear();
          _pwdcontroller.clear();
          return;
        }
      }
    } catch (error) {
      print(error);
    }
    _emcontroller.clear();
    _pwdcontroller.clear();
    setState(() {
      _is_loading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Center(
          child: Text(
        'Unable to login ',
        style: TextStyle(color: Colors.red),
      )),
      duration: const Duration(milliseconds: 1500),
      width: 280.0,
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 5.0,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
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
          return false;
        },
        child: Stack(children: [
          Scaffold(
              body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                // logo
                "assets/Redana_logo.jpeg",
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 40),
              const Text(
                "Hotel Login",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Container(
                  margin: const EdgeInsets.only(top: 20),
                  width: 250,
                  child: TextField(
                    controller: _emcontroller,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          gapPadding: 4.0,
                          borderRadius: BorderRadius.circular(150),
                        ),
                        labelText: 'Email'),
                  )),
              Container(
                  margin: const EdgeInsets.only(top: 20),
                  width: 250,
                  child: TextField(
                    controller: _pwdcontroller,
                    obscureText: true,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          gapPadding: 4.0,
                          borderRadius: BorderRadius.circular(150),
                        ),
                        labelText: 'Password'),
                  )),
              GestureDetector(
                  // hotel login button
                  onTap: () => login(context),
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 20),
                      width: 250,
                      height: 80,
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(150),
                        color: Colors.red,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            'Login',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16),
                          )
                        ],
                      ),
                    ),
                  ))
            ],
          )),
          if (_is_loading)
            const Opacity(
              opacity: 0.8,
              child: ModalBarrier(dismissible: false, color: Colors.black),
            ),
          if (_is_loading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ]));
  }
}
