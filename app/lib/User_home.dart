// ignore: file_names
import 'package:flutter/material.dart';
import 'package:http/http.dart' as HTTP;
import 'dart:convert' as convert;
import 'package:google_sign_in/google_sign_in.dart';

import 'Hotel.dart';
import 'Schema.dart';
import 'global.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _userhome createState() => _userhome();
}

// ignore: camel_case_types
class _userhome extends State<UserHome> {
  late Future<List<Hotel>> hotels;
  List<HotelCard> hotels_card = [];

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
      hotels_card.add(HotelCard(hotel));
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

    Navigator.pop(context);
  }

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
              onPressed: () => {logout(context)},
              icon: const Icon(
                Icons.exit_to_app,
                color: Colors.white,
              ))
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
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
                    return const Center(child: Text('Something went wrong :('));
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
    );
  }
}
