import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:zoo_mobile/models/news/full_news.dart';
import 'package:zoo_mobile/widgets/clickable_image.dart';
import 'package:zoo_mobile/widgets/downloading_widgets.dart';
import 'package:http/http.dart' as http;

class FullNewsViewer extends StatefulWidget {
  final String _newsUrl;

  FullNewsViewer(this._newsUrl);

  _FullNewsViewerState createState() => _FullNewsViewerState();
}

class _FullNewsViewerState extends State<FullNewsViewer> {
  Future<FullNews> _newsFuture;

  FullNews _fullNews;

  @override
  void initState() {
    super.initState();
    _newsFuture = fetchFullNews(widget._newsUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getFutureBuilder(),
    );
  }

  //Future which solve what widget should be displayed
  Widget getFutureBuilder() {
    return FutureBuilder(
      future: _newsFuture,
      builder: (context, snapshot) {
        //If data downloaded
        if (snapshot.hasData) {
          _fullNews = snapshot.data;
          return getListView();
        } else if (snapshot.hasError) {
          //If error occurred
          print(snapshot.error);
          showToast('Проверьте интернет соединение');

          // Close news if there is no connectivity
          WidgetsBinding.instance
              .addPostFrameCallback((_) => Navigator.pop(context));
        }

        //Default widget
        return getCircularProgress();
      },
    );
  }

  //Getting progress bar until downloading finish
  Widget getCircularProgress() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Соединение..'),
      ),
      body: Center(
        child: getProgressBar(),
      ),
    );
  }

  //Getting list view which contains content
  Widget getListView() {
    return Scaffold(
      body: CustomScrollView(
        key: PageStorageKey("FullNewsList"),
        slivers: <Widget>[
          //AppBar
          SliverAppBar(
            pinned: true,
            elevation: 3,
            title: Text(
              _fullNews.title,
            ),
            expandedHeight: 250,
            //HEADER IMAGE
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                _fullNews.headerImageUrl,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),

          //Content
          SliverList(
            delegate: SliverChildListDelegate(
              <Widget>[
                // TEXT OF NEWS
                Container(
                  padding: EdgeInsets.only(left: 16.0, right: 16.0),
                  child: Text(
                    _fullNews.text,
                    softWrap: true,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17.0,
                    ),
                  ),
                ),

                // CONTENT OF NEWS
                ClickableImages(
                  _fullNews.imageUrls,
                  pLeft: 32.0,
                  pRight: 32.0,
                  pTop: 16.0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ///Asynchronous fetching data from url
  /// and then parse data
  Future<FullNews> fetchFullNews(String url) async {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<String> imagesUrl = [];
      //Parsing data from page
      var titleAndImage =
          parse(response.body).getElementsByClassName('jbimage-link');
      var descr = parse(response.body)
          .getElementsByClassName('element-textarea')[0]
          .getElementsByTagName('p');
      var gallery =
          parse(response.body).getElementsByClassName('element-jbgallery');

      //Parsing gallery of photos if it is exist in a news
      if (gallery.length > 0) {
        gallery = gallery[0].getElementsByTagName('a');
        //Adding images to list
        for (int i = 0; i < gallery.length; i++)
          imagesUrl.add(gallery[i].attributes['href']);
      }

      var title = '';
      var image = '';
      if (titleAndImage.length != 0) {
        title = titleAndImage[0].attributes['title'];
        image = titleAndImage[0].attributes['href'];
      }
      //Building description
      String description = '';
      for (int i = 0; i < descr.length; i++) {
        description += descr[i].text + '\n';
      }

      FullNews news = new FullNews(image, title, description, imagesUrl);
      return news;
    } else
      throw Exception('Проверьте интернет соединение');
  }
}
