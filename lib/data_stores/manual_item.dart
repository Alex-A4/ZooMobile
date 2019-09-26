

///Class describes one element from manual
class ManualItem {
  final String _imageUrl;
  final String _description;
  final String _pageUrl;

  ManualItem(this._imageUrl, this._description, this._pageUrl);

  String get pageUrl => _pageUrl;

  String get description => _description;

  String get imageUrl => _imageUrl;
}