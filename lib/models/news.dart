
/// Class describes one news
class News {
  final String _title;
  final String _description;
  final String _imageUrl;
  final String _pageUrl;
  final String _postDate;

  News(this._title, this._description, this._imageUrl, this._postDate, this._pageUrl) :
        assert(_title != null),
        assert(_description != null),
        assert(_imageUrl != null),
        assert(_postDate != null),
        assert (_pageUrl != null);


  String get pageUrl => _pageUrl;

  String get postDate => _postDate;

  String get imageUrl => _imageUrl;

  String get description => _description;

  String get title => _title;
}