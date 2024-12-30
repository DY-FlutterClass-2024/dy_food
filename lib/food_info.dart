class FoodInfo {
  String name;
  List<int> allergens;

  FoodInfo({
    required this.name,
    required this.allergens,
  });

  factory FoodInfo.fromData(String data) {
    print(data);

    String name;
    List<int> allergens;

    if (!data.contains('(')) {
      name = data;
      allergens = [];

      return FoodInfo(name: name, allergens: allergens);
    }

    name = data.split(' (')[0];
    print(name);
    allergens = data
        .split(' (')[1]
        .replaceAll(')', '')
        .split('.')
        .map((allergens) => int.parse(allergens))
        .toList();
    print(allergens);

    return FoodInfo(name: name, allergens: allergens);
  }
}
