import 'package:flutter/material.dart';
import 'package:zoo_mobile/src/content_providers/content_provider.dart';
import 'package:zoo_mobile/src/models/news/full_news.dart';
import 'package:zoo_mobile/src/widgets/clickable_image.dart';
import 'package:zoo_mobile/src/widgets/downloading_widgets.dart';

class FullNewsViewer extends StatelessWidget {
  final String newsUrl;

  FullNewsViewer(this.newsUrl);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future:
            ContentProvider.getInstance<FullNews>().fetchObject(newsUrl),
        builder: (context, snapshot) {
          //If data downloaded
          if (snapshot.hasData) {
            return getListView(snapshot.data);
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
      ),
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
  Widget getListView(FullNews news) {
    return Scaffold(
      body: CustomScrollView(
        key: PageStorageKey("FullNewsList"),
        slivers: <Widget>[
          //AppBar
          SliverAppBar(
            pinned: true,
            elevation: 3,
            title: Text(
              news.title,
            ),
            expandedHeight: 250,
            //HEADER IMAGE
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                news.headerImageUrl,
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
                    news.text,
                    softWrap: true,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17.0,
                    ),
                  ),
                ),

                // CONTENT OF NEWS
                ClickableImages(
                  news.imageUrls,
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
}
