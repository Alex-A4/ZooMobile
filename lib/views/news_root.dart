import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:zoo_mobile/models/news_store.dart';
import 'package:zoo_mobile/widgets/downloading_widgets.dart';
import '../models/news.dart';
import 'package:http/http.dart' as http;
import 'full_news_viewer.dart';

class NewsView extends StatefulWidget {
  NewsView({Key key}): super(key: key);

  @override
  _NewsViewState createState() => _NewsViewState();
}



class _NewsViewState extends State<NewsView> {
  String _title = 'Новости';

  Future<List<News>> news;


  @override
  void initState() {
    super.initState();
    startDownloading();
  }

  void startDownloading(){
    setState(() {
      news = fetchNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          child: Image(image: AssetImage('assets/logo.png'),),
          padding: EdgeInsets.only(left:10.0, top:5.0, bottom: 5.0),
        ),
        title: Text(_title),
      ),
      body: getFutureBuilder(),

    );
  }


  Widget getFutureBuilder() {
    return FutureBuilder<List<News>>(
      future: news,
      builder: (context, snapshot) {

        //If news have been downloaded but internet disabled
        if (NewsStore.getStore().news.isNotEmpty) {
          _title = 'Новости';
          return getListView();
        }

        //If downloading finished
        if (snapshot.hasData) {
          NewsStore.getStore().updateNews(snapshot.data);
          _title = 'Новости';
          return getListView();
        } else if (snapshot.hasError) {
          // If error occurred
          showToast(snapshot.error.toString().replaceFirst('Exception: ', ''));

          _title = 'Ожидание сети..';
          return getUpdateScreen(() {
            setState(() {
              _title = 'Новости';
              startDownloading();
            });
          });
        }

        //Until downloading finishes, show progress bar
        _title = 'Соединение..';
        return getProgressBar();
      },
    );
  }

  Widget getListView() {
    return ListView.builder(
        key: PageStorageKey('NewsKey'),
        padding: EdgeInsets.only(top: 8.0),
        itemCount: NewsStore.getStore().news.length,
        itemBuilder: (BuildContext context, int pos) {
          return _NewsListItem(NewsStore.getStore().news[pos]);
        }
    );
  }


  /// Fetching news from web-site
  Future<List<News>> fetchNews() async {
    //Checking internet connection
    var connectivityResult = await (new Connectivity().checkConnectivity());

    if (connectivityResult != ConnectivityResult.mobile
        && connectivityResult != ConnectivityResult.wifi)
      throw Exception('Отсутствует интернет соединение');


    final response = await http.get('http://yar-zoo.ru/home/news.html');

    if (response.statusCode == 200) {
      List<News> news = [];

      //Parsing data from page
      var dateParse = parse(response.body).getElementsByClassName('element-itempublish_up');
      var descr = parse(response.body).getElementsByClassName('element-textarea');
      var docs = parse(response.body).getElementsByClassName('item-image');

      for (int i = 0; i < docs.length; i++) {
        var pageHref = docs[i].getElementsByTagName('a')[0].attributes['href'];
        var title = docs[i].getElementsByTagName('a')[0].attributes['title'];
        var image = docs[i].getElementsByTagName('img')[0].attributes['src'];
        var description = descr[i].getElementsByTagName('p')[0].text;
        var date = dateParse[i].text.trim();
        news.add(new News(title, description, image, date, pageHref));
      }

      return news;
    } else throw Exception('Проверьте интернет соединение');
  }

}


/// Class describes news item from list
class _NewsListItem extends StatelessWidget {
  final News _news;
  _NewsListItem(this._news);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => FullNewsViewer(_news.pageUrl)
          ),
        );
      },

      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Text with title of news
            Container(
              padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
              child: Text(
                _news.title,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.black,
                ),
              ),
            ),

            // Text with date
            Container(
              padding: EdgeInsets.only(left: 16.0, right: 16.0),
              child: Text(
                _news.postDate,
                textAlign: TextAlign.start,
                style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black45
                ),
              ),
            ),

            //An image which placed into the center
            Center(
              child: Container(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  child: Image.network(
                    _news.imageUrl,
                    width: MediaQuery.of(context).size.width - 150,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
            ),

            // A description of news
            Container(
              padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
              child: Text(
                _news.description,
                textAlign: TextAlign.start,
                softWrap: true,
                style: TextStyle(
                    fontSize: 17.0,
                    color: Colors.black45
                ),
              ),
            ),

            Divider(color: Colors.black26),
          ],
        ),
    );
  }

}
