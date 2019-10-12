import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:zoo_mobile/models/manual/manual_item.dart';
import 'package:zoo_mobile/repository/manual_repository.dart';
import 'package:zoo_mobile/widgets/downloading_widgets.dart';

import 'animals_category.dart';

/// Class describes main page of zoo manual
/// This page contains categories of animals
class ManualCategoryView extends StatefulWidget {
  ManualCategoryView({Key key}) : super(key: key);

  _ManualCategoryViewState createState() => _ManualCategoryViewState();
}

class _ManualCategoryViewState extends State<ManualCategoryView> {
  Future<List<ManualItem>> _items;
  String _title = 'Справочник';

  @override
  void initState() {
    super.initState();
    startDownloading();
  }

  void startDownloading() {
    setState(() {
      _items = fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          child: Image(
            image: AssetImage('assets/logo.png'),
          ),
          padding: EdgeInsets.only(left: 10.0, top: 5.0, bottom: 5.0),
        ),
        title: Text(_title),
      ),
      body: getFutureBuilder(),
    );
  }

  //Getting future builder which solve what to show
  Widget getFutureBuilder() {
    return FutureBuilder<List<ManualItem>>(
      future: _items,
      builder: (context, snapshot) {
        //If manual have been downloaded but internet disabled
        if (ManualStore.getStore().items.isNotEmpty) {
          _title = 'Справочник';
          return getGridView();
        }

        //If downloading finished
        if (snapshot.hasData) {
          ManualStore.getStore().updateManual((snapshot.data));
          _title = 'Справочник';
          return getGridView();
        } else if (snapshot.hasError) {
          // If error occurred
          showToast(snapshot.error.toString().replaceFirst('Exception: ', ''));

          _title = 'Ожидание сети..';
          return getUpdateScreen(() {
            setState(() {
              _title = 'Справочник';
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

  ///GridView with the items of manual
  Widget getGridView() {
    return GridView.builder(
      key: PageStorageKey('ManualKey'),
      padding: EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisSpacing: 10,
        crossAxisCount: 2,
        crossAxisSpacing: 10,
      ),
      itemCount: ManualStore.getStore().items.length,
      itemBuilder: (BuildContext context, int pos) {
        return ManualCategoryListItem(ManualStore.getStore().items[pos]);
      },
    );
  }
}

/// One item of list from manual
class ManualCategoryListItem extends StatelessWidget {
  final ManualItem _item;

  ManualCategoryListItem(this._item);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AnimalsCategory(_item),
        ));
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
        ),
        elevation: 5.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            //Image of manual
            Image.network(
              _item.imageUrl,
              fit: BoxFit.fitWidth,
            ),

            //Description of manual
            Text(
              _item.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

///Downloading items of manual and adding them to list
Future<List<ManualItem>> fetchData() async {
  //Checking connectivity
  var connectivityResult = await (new Connectivity().checkConnectivity());

  if (connectivityResult != ConnectivityResult.mobile &&
      connectivityResult != ConnectivityResult.wifi)
    throw Exception('Отсутствует интернет соединение');

  //Getting data
  final response = await http.get('http://yar-zoo.ru/animals.html');

  if (response.statusCode == 200) {
    List<ManualItem> items = [];

    //Parsing data from page
    var elements =
        parse(response.body).getElementsByClassName('subcategory-image');

    for (int i = 0; i < elements.length; i++) {
      var body = elements[i].getElementsByTagName('a');

      String imageUrl =
          elements[i].getElementsByTagName('img')[0].attributes['src'];
      String description =
          body[0].attributes['title'].replaceFirst('<br/>', '\n');
      String pageUrl = 'http://yar-zoo.ru${body[0].attributes['href']}';

      items.add(new ManualItem(imageUrl, description, pageUrl));
    }

    return items;
  } else
    throw Exception('Проверьте интернет соединение');
}
