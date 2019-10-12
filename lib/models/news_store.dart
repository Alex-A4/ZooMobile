import 'news.dart';

///Singleton store of news
class NewsStore {
  List<News> _news = [];
  static NewsStore _sStore;

  static NewsStore getStore() {
    if (_sStore == null) _sStore = new NewsStore();

    return _sStore;
  }

  void updateNews(List<News> news) {
    _news = news;
  }

  List<News> get news => _news;
}
