import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'User_home.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  // handle google auth
  Future<void> signin(context) async {
    //TODO implement google auth login
    try {
      await GoogleSignIn().signIn().then((userdata) {
        print(userdata);
        go_to_home(context);
      });
    } catch (error) {
      print(error);
    }

    // temp go to home
    //go_to_home(context);
  }

  // switches to the home page
  // ignore: non_constant_identifier_names
  void go_to_home(context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const UserHome()));
  }

  @override
  Widget build(BuildContext context) {
    GoogleSignIn().isSignedIn().then(
      (value) {
        if (value) go_to_home(context);
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
