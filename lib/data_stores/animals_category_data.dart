
//Class describes one element of animal category
class AnimalCategory {
  final String _pageUrl;
  final String _imageUrl;
  final String _title;

  AnimalCategory(this._pageUrl, this._imageUrl, this._title);

  String get title => _title;

  String get imageUrl => _imageUrl;

  String get pageUrl => _pageUrl;
}


//Singleton store of animals category
class AnimalCategoryStore {
  static AnimalCategoryStore _store;

  List<AnimalCategory> _animals = [];

  static AnimalCategoryStore getStore() {
    if (_store == null)
      _store = new AnimalCategoryStore();

    return _store;
  }

  List<AnimalCategory> get animals => _animals;

  void updateAnimals(List<AnimalCategory> list) {
    _animals = list;
  }
}