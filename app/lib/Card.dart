// ignore: file_names
import 'package:flutter/material.dart';

// Hotel class
class Hotel {
  String name;
  List dishes;

  Hotel(this.name, this.dishes);

  factory Hotel.fromJson(dynamic json) {
    return Hotel(json['name'] as String, json["dishes"] as List);
  }
}

// ignore: must_be_immutable
class HotelCard extends StatefulWidget {
  Hotel hotel;

  HotelCard(this.hotel, {super.key});

  @override
  // ignore: library_private_types_in_public_api
  _hotelcard createState() => _hotelcard();
}

// ignore: camel_case_types
class _hotelcard extends State<HotelCard> {
  @override
  Widget build(BuildContext context) {
    Hotel hotel = widget.hotel;

    return GestureDetector(
        child: Card(
      margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      child: Row(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            height: 100,
            child: Image.asset(
              "hotel_icon.jpg",
              width: 80,
              height: 80,
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          Text(
            hotel.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          )
        ],
      ),
    ));
  }
}
