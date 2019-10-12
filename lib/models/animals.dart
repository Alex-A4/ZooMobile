
class Animal {
  final String _description;
  final Map<String, String> _tabElements;

  Animal(this._description, this._tabElements);

  Map<String, String> get tabElements => _tabElements;

  String get description => _description;
}