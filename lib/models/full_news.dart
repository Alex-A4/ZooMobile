/// Class describes news with full content
class FullNews {
  final String _headerImageUrl;
  final String _title;
  final String _text;
  final List<String> _imageUrls;

  FullNews(this._headerImageUrl, this._title, this._text, this._imageUrls);

  List<String> get imageUrls => _imageUrls;

  String get text => _text;

  String get title => _title;

  String get headerImageUrl => _headerImageUrl;
}