class Shop {
  String message = '';
  String owner = '';
  List<ShopItem> items = [];

  Shop();

  Shop.fromJson(Map<String, dynamic> json) {
    owner = json['name'] ?? '';
    final shop = json['shop'] ?? {};
    message = shop['message'] ?? '';
    final itemsJson = shop['items'] ?? [];
    for (final item in itemsJson) {
      items.add(ShopItem.fromJson(item));
    }
  }
}

class ShopItem {
  String name = '';
  int cost = 0;

  ShopItem();

  ShopItem.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? '';
    cost = json['cost'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['name'] = name;
    json['cost'] = cost;
    return json;
  }
}
