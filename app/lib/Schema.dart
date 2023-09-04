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
  String name;
  late Future<List<Dish>> dishes;

  Hotel(
    this.name,
  );

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
