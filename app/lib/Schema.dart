import 'global.dart';
import 'package:http/http.dart' as HTTP;
import 'dart:convert' as convert;

// Dish class
class Dish {
  String name;
  int price;
  bool vegan;

  Dish({required this.name, required this.price, required this.vegan});

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(name: json['name'], price: json['price'], vegan: json['vegan']);
  }
}

// Hotel class
class Hotel {
  String name, addr, ph_no;
  late Future<List<Dish>> dishes;

  Hotel(this.name, this.addr, this.ph_no);

  Future<List<Dish>> get_dishes() async {
    String api = '/dishes?name=$name';
    var url = Uri.parse(server_address + api);

    List<Dish> _dishes = [];
    try {
      var response = await HTTP.get(url).whenComplete(() {});
      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body) as List<dynamic>;
        print(jsonResponse);
        for (var element in jsonResponse) {
          print(Dish.fromJson(element).name);
          _dishes.add(Dish.fromJson(element));
        }
      }
    } on Exception catch (e) {
      print(e);
      throw Exception(e);
    }
    return _dishes;
  }
}

class Hotel_order {
  // ignore: non_constant_identifier_names
  String user_name;
  // ignore: non_constant_identifier_names
  Map<String, dynamic> order_items;
  int total;
  String order_id;
  bool completed;

  Hotel_order(this.user_name, this.order_items, this.total, this.completed,
      this.order_id);

  factory Hotel_order.fromJson(Map<String, dynamic> json) {
    return Hotel_order(
        json["user_name"],
        json["order_items"] as Map<String, dynamic>,
        json["total"],
        json["completed"],
        json["order_id"]);
  }
}

class Cart_obj {
  late String? user_name, user_email, hotel_name;
  late List<Dish>? cart_items;

  Cart_obj(this.user_name, this.user_email, [this.hotel_name, this.cart_items]);
}
