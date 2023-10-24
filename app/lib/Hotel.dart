// ignore: file_names
import 'package:Redana/global.dart';
import 'package:flutter/material.dart';

import "Schema.dart";
import 'Cart.dart';

// ignore: must_be_immutable
class HotelCard extends StatefulWidget {
  Hotel hotel;
  String? user_name, user_email;

  HotelCard(this.user_email, this.user_name, this.hotel, {super.key});

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
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      HotelPage(widget.user_email, widget.user_name, hotel)));
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          child: Column(
            children: <Widget>[
              Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  height: 100,
                  child: Image.network(
                      "$server_address/hotelimg?hotel_name=${widget.hotel.name}")),
              const SizedBox(
                height: 2,
              ),
              Text(
                widget.hotel.name,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              )
            ],
          ),
        ));
  }
}

// ignore: must_be_immutable
class HotelPage extends StatefulWidget {
  String? user_name, user_email;
  @override
  // ignore: library_private_types_in_public_api
  _hotelpage createState() => _hotelpage();

  Hotel hotel;

  HotelPage(this.user_email, this.user_name, this.hotel, {super.key});
}

// ignore: camel_case_types
class _hotelpage extends State<HotelPage> {
  // Contains all the items in cart
  List<Dish> cart = [];
  late Cart_obj cart_obj;

  @override
  void initState() {
    widget.hotel.dishes =
        widget.hotel.get_dishes().whenComplete(() => print("fetched dishes"));
    super.initState();
  }

  void _showCloseDialog(BuildContext context) {
    // Check if the cart is not empty
    if (cart.isNotEmpty) {
      showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: const Text("Warning"),
                content: const Text(
                    "Closing this page will remove the items from your cart!!"),
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
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text("Ok"),
                  )
                ],
              ));
    }
    // Cart is empty so just close the page
    else {
      Navigator.pop(context);
    }
  }

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
          onPressed: () => _showCloseDialog(context),
          icon: const Icon(Icons.arrow_back), color: Colors.white,
        ),
        actions: [
          // Cart button
          IconButton(
              onPressed: () => {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Cart(Cart_obj(
                                widget.user_email,
                                widget.user_name,
                                widget.hotel.name,
                                cart))))
                  },
              icon: const Icon(Icons.trolley),
              color: Colors.white),
        ],
      ),
      body: SingleChildScrollView(
          // Display the dishes available in the hotel
          child: FutureBuilder(
              future: widget.hotel.dishes,
              builder:
                  (BuildContext context, AsyncSnapshot<List<Dish>> snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("There was an error"));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data?.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 10),
                          child: SizedBox(
                            height: 80,
                            child: Stack(
                              children: <Widget>[
                                // Tile containing name price color
                                ListTile(
                                  leading: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Icon(
                                        Icons.crop_square_sharp,
                                        color:
                                            // check vegan
                                            snapshot.data![index].vegan
                                                ? Colors.green
                                                : Colors.red,
                                        size: 32,
                                      ),
                                      Icon(Icons.circle,
                                          color:
                                              // check vegan
                                              snapshot.data![index].vegan
                                                  ? Colors.green
                                                  : Colors.red,
                                          size: 13),
                                    ],
                                  ),
                                  title: Text(snapshot.data![index].name),
                                  subtitle:
                                      Text("₹${snapshot.data![index].price}"),
                                ),

                                // Check if it is already in cart
                                cart.contains(snapshot.data![index])
                                    ?
                                    // Remove from cart
                                    Align(
                                        alignment: Alignment.bottomRight,
                                        child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                cart.remove(
                                                    snapshot.data![index]);
                                              });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.red)),
                                              margin: const EdgeInsets.all(5),
                                              width: 90,
                                              height: 35,
                                              child: const Padding(
                                                  padding: EdgeInsets.all(5),
                                                  child: Center(
                                                      child: Text(
                                                    "Remove",
                                                    style: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold),
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
                                                cart.add(snapshot.data![index]);
                                              });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.red)),
                                              margin: const EdgeInsets.all(5),
                                              width: 70,
                                              height: 35,
                                              child: Stack(
                                                children: <Widget>[
                                                  Align(
                                                      alignment:
                                                          Alignment.topRight,
                                                      child: Container(
                                                        width: 18,
                                                        height: 18,
                                                        decoration: const BoxDecoration(
                                                            border: Border(
                                                                left: BorderSide(
                                                                    color: Colors
                                                                        .red),
                                                                bottom: BorderSide(
                                                                    color: Colors
                                                                        .red))),
                                                        child: const Center(
                                                            child: Text(
                                                          "+",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red),
                                                        )),
                                                      )),
                                                  const Align(
                                                      alignment:
                                                          Alignment.bottomLeft,
                                                      child: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 10,
                                                                  bottom: 5),
                                                          child: Text(
                                                            "Add",
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ))),
                                                ],
                                              ),
                                            )),
                                      )
                              ],
                            ),
                          ));
                    });
              })),
    );
  }
}
