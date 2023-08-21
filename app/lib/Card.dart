// ignore: file_names
import 'package:flutter/material.dart';

// Dish class
class Dish {
  String name;
  int price;
  bool vegan;

  Dish(this.name, this.price, this.vegan);
}

// Hotel class
class Hotel {
  String name;
  List<Dish> dishes;

  Hotel(this.name, this.dishes);

  factory Hotel.fromJson(dynamic json) {
    return Hotel(json['name'] as String, json["dishes"] as List<Dish>);
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
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => HotelPage(hotel)));
        },
        child: Card(
          elevation: 4,
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
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              )
            ],
          ),
        ));
  }
}

// ignore: must_be_immutable
class HotelPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _hotelpage createState() => _hotelpage();

  Hotel hotel;

  HotelPage(this.hotel, {super.key});
}

// ignore: camel_case_types
class _hotelpage extends State<HotelPage> {
  // Contains all the items in cart
  List<Dish> cart = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          widget.hotel.name,
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          // Back to home screen button
          // TODO check if cart is empty and go back
          onPressed: () => {Navigator.pop(context)},
          icon: const Icon(Icons.arrow_back), color: Colors.white,
        ),
        actions: [
          // Cart button
          // TODO implement cart checkout page
          IconButton(
              onPressed: () => {},
              icon: const Icon(Icons.trolley),
              color: Colors.white),
        ],
      ),
      body: SingleChildScrollView(
          // Display the dishes available in the hotel
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.hotel.dishes.length,
              itemBuilder: (context, index) {
                return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 10),
                    child: SizedBox(
                      height: 80,
                      child: Stack(
                        children: <Widget>[
                          ListTile(
                            leading: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.crop_square_sharp,
                                  color:
                                      // check vegan
                                      widget.hotel.dishes[index].vegan
                                          ? Colors.green
                                          : Colors.red,
                                  size: 32,
                                ),
                                Icon(Icons.circle,
                                    color:
                                        // check vegan
                                        widget.hotel.dishes[index].vegan
                                            ? Colors.green
                                            : Colors.red,
                                    size: 13),
                              ],
                            ),
                            title: Text(widget.hotel.dishes[index].name),
                            subtitle:
                                Text("₹${widget.hotel.dishes[index].price}"),
                          ),

                          // Check if it is already in cart
                          cart.contains(widget.hotel.dishes[index])
                              ?
                              // Remove from cart
                              Align(
                                  alignment: Alignment.bottomRight,
                                  child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          cart.remove(
                                              widget.hotel.dishes[index]);
                                        });
                                      },
                                      child: Container(
                                        decoration:
                                            BoxDecoration(border: Border.all()),
                                        margin: const EdgeInsets.all(5),
                                        width: 90,
                                        height: 35,
                                        child: const Padding(
                                            padding: EdgeInsets.all(5),
                                            child: Center(
                                                child: Text(
                                              "Remove",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold),
                                            ))),
                                      )),
                                )
                              :

                              // Add to cart
                              Align(
                                  alignment: Alignment.bottomRight,
                                  child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          cart.add(widget.hotel.dishes[index]);
                                        });
                                      },
                                      child: Container(
                                        decoration:
                                            BoxDecoration(border: Border.all()),
                                        margin: const EdgeInsets.all(5),
                                        width: 70,
                                        height: 35,
                                        child: Stack(
                                          children: <Widget>[
                                            Align(
                                                alignment: Alignment.topRight,
                                                child: Container(
                                                  width: 15,
                                                  height: 15,
                                                  decoration:
                                                      const BoxDecoration(
                                                          border: Border(
                                                              left:
                                                                  BorderSide(),
                                                              bottom:
                                                                  BorderSide())),
                                                  child: const Center(
                                                      child: Text("+")),
                                                )),
                                            const Align(
                                                alignment: Alignment.bottomLeft,
                                                child: Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 10, bottom: 5),
                                                    child: Text(
                                                      "Add",
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ))),
                                          ],
                                        ),
                                      )),
                                )
                        ],
                      ),
                    ));
              })),
    );
  }
}
