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
