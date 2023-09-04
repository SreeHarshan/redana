import 'package:flutter/material.dart';

import 'Schema.dart';

// ignore: must_be_immutable
class Cart extends StatefulWidget {
  List<Dish> cart_items;

  Cart(this.cart_items, {super.key});

  @override
  // ignore: library_private_types_in_public_api
  _cart createState() => _cart();
}

// ignore: camel_case_types
class _cart extends State<Cart> {
  List<int> q = [];

  @override
  void initState() {
    super.initState();

    q = List.generate(widget.cart_items.length, (index) => 1);
  }

  // ignore: non_constant_identifier_names
  void _decrease_quantity(int idx) {
    setState(() {
      if (q[idx] > 1) q[idx]--;
    });
  }

  // ignore: non_constant_identifier_names
  void _increase_quantity(int idx) {
    setState(() {
      q[idx]++;
    });
  }

  int _cart_total() {
    int tot = 0;
    for (int i = 0; i < q.length; i++) {
      tot += widget.cart_items[i].price * q[i];
    }

    return tot;
  }

  //TODO remove this function and add widget directly
  // ignore: non_constant_identifier_names
  Widget _reserve_button(BuildContext context) {
    // Check if he cart is empty
    if (q.isNotEmpty) {
      return FloatingActionButton.extended(
          // TODO implement this
          onPressed: () => {},
          label: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: const Text(
              "Place Order",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ));
    }

    // Return empty container if it is empty
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          "Cart",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          // Back to Hotel screen button
          onPressed: () => {Navigator.pop(context)},
          icon: const Icon(Icons.arrow_back), color: Colors.white,
        ),
      ),
      body:
          // Check if cart is empty
          q.isNotEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SingleChildScrollView(
                        child: Column(
                      children: <Widget>[
                        ListView.builder(
                            itemCount: widget.cart_items.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Card(
                                elevation: 4,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 10),
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
                                                widget.cart_items[index].vegan
                                                    ? Colors.green
                                                    : Colors.red,
                                            size: 32,
                                          ),
                                          Icon(Icons.circle,
                                              color:
                                                  // check vegan
                                                  widget.cart_items[index].vegan
                                                      ? Colors.green
                                                      : Colors.red,
                                              size: 13),
                                        ],
                                      ),

                                      // Name
                                      title:
                                          Text(widget.cart_items[index].name),

                                      // Price
                                      subtitle: Text(
                                          "₹${widget.cart_items[index].price * q[index]}"),
                                    ),

                                    // Change quantity
                                    Align(
                                        alignment: Alignment.bottomRight,
                                        child: SizedBox(
                                          width: 90,
                                          height: 50,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              GestureDetector(
                                                  onTap: () =>
                                                      _decrease_quantity(index),
                                                  child: const Text(
                                                    "-",
                                                    style:
                                                        TextStyle(fontSize: 15),
                                                  )),
                                              Text(
                                                "${q[index]}",
                                                style: const TextStyle(
                                                    fontSize: 15),
                                              ),
                                              GestureDetector(
                                                onTap: () =>
                                                    _increase_quantity(index),
                                                child: const Text(
                                                  "+",
                                                  style:
                                                      TextStyle(fontSize: 15),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                  ],
                                ),
                              );
                            }),
                      ],
                    )),

                    // Cart subtotal and reserve
                    Container(
                        width: double.infinity,
                        height: 150,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 35, vertical: 20),
                        color: Colors.red,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Cart Subtotal : ${_cart_total()}",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Center(child: _reserve_button(context)),
                          ],
                        )),
                  ],
                )

              // Empty cart display
              : const Center(
                  child: Text("Oops, your cart is empty !"),
                ),
      //floatingActionButton: _reserve_button(context),
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
