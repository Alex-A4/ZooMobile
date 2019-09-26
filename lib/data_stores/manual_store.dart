


import 'manual_item.dart';

///Singleton store of manual elements
class ManualStore {
  static ManualStore _store;

  List<ManualItem> _items = [];

  // Store getter
  static ManualStore getStore() {
    if (_store == null)
      _store = new ManualStore();

    return _store;
  }

  void updateManual(List<ManualItem> list) {
    _items = list;
  }

  List<ManualItem> get items => _items;
}