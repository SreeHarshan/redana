// ignore: file_names
import 'package:flutter/material.dart';

import 'Card.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _userhome createState() => _userhome();
}

// ignore: camel_case_types
class _userhome extends State<UserHome> {
  List<Hotel> hotels = [];
  List<HotelCard> hotels_card = [];

  void get_hotels() {
    //get the hotels from the database

    //temp add hotels
    hotels.add(Hotel("Hotel A", ["Dish A", "Dish B", "Dish C"]));
    hotels.add(Hotel("Hotel B", ["Dish A", "Dish B", "Dish C"]));
    hotels.add(Hotel("Hotel C", ["Dish A", "Dish B", "Dish C"]));
    hotels.add(Hotel("Hotel D", ["Dish A", "Dish B", "Dish C"]));
    hotels.add(Hotel("Hotel E", ["Dish A", "Dish B", "Dish C"]));
    hotels.add(Hotel("Hotel F", ["Dish A", "Dish B", "Dish C"]));
    //Convert hotels to cards
    for (var hotel in hotels) {
      hotels_card.add(HotelCard(hotel));
    }
  }

  @override
  void initState() {
    super.initState();
    //temp call
    get_hotels();
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
              onPressed: () => {Navigator.pop(context)},
              icon: const Icon(
                Icons.exit_to_app,
                color: Colors.white,
              ))
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left: 15),
              child: const Text(
                "Hotels nearby",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            ListView.builder(
                shrinkWrap: true,
                itemCount: hotels_card.length,
                itemBuilder: (context, index) {
                  return hotels_card[index];
                })
          ],
        ),
      ),
    );
  }
}
