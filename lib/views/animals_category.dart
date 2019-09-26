import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:zoo_mobile/data_stores/animals_category_data.dart';
import 'package:zoo_mobile/data_stores/manual_item.dart';
import 'package:zoo_mobile/widgets/downloading_widgets.dart';
import 'package:http/http.dart' as http;
import 'animals_viewer.dart';


///Class to display list of animals by specified category
class AnimalsCategory extends StatefulWidget {
  final ManualItem _manualItem;

  AnimalsCategory(this._manualItem);

  @override
  _AnimalsCategoryState createState() => _AnimalsCategoryState();

}

class _AnimalsCategoryState extends State<AnimalsCategory> {
  Future<List<AnimalCategory>> _animals;

  @override
  void initState() {
    super.initState();
    _animals = fetchData(widget._manualItem.pageUrl);
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
      future: _animals,
      builder: (context, snapshot){
        //If data downloaded
        if (snapshot.hasData) {
          AnimalCategoryStore.getStore().updateAnimals(snapshot.data);

          //If count of animals more then 5, then show like grid else like list
          return Scaffold(
            appBar: AppBar(
              title: Text(widget._manualItem.description),
            ),
            body: getGridView(),
          );
        } else if (snapshot.hasError) {
          //If error occurred
          showToast('Проверьте интернет соединение');

          // Close categories if there is no connectivity
          Navigator.pop(context);
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
        title: Text(
            'Соединение..'
        ),
      ),
      body: Center(
        child: getProgressBar(),
      ),
    );
  }


  //Getting grid view which contains content
  //If there is more then 5 entries then show like 2-column grid
  // else like 1-column grid
 Widget getGridView() {
    return GridView.builder(
        key: PageStorageKey('AnimalsCategoryGridKey'),
        padding: EdgeInsets.all(8.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: AnimalCategoryStore.getStore().animals.length,
        itemBuilder: (context, pos) {
          return _AnimalsCategoryItem(AnimalCategoryStore.getStore().animals[pos]);
        },
      );
 }

}


//Widget contains image of category and title
class _AnimalsCategoryItem extends StatelessWidget{
  final AnimalCategory _category;

  _AnimalsCategoryItem(this._category);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AnimalsViewer(_category)),
        );
      },
      child: Card(
        elevation: 5.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(9.0),
              child: Image.network(
                _category.imageUrl,
                fit: BoxFit.fitWidth,
              ),
            ),

            Expanded(
              child: Text(
                _category.title,
                softWrap: true,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



/// Fetching animals from web-site
Future<List<AnimalCategory>> fetchData(String url) async {
  //Checking internet connection
  var connectivityResult = await (new Connectivity().checkConnectivity());

  if (connectivityResult != ConnectivityResult.mobile
      && connectivityResult != ConnectivityResult.wifi)
    throw Exception('Отсутствует интернет соединение');


  final response = await http.get(url);


  if (response.statusCode == 200) {
    List<AnimalCategory> animals = [];

    //Parsing data from page
    var body = parse(response.body).getElementsByClassName('item-image');

    for (int i = 0; i < body.length; i++) {
      String title = body[i].getElementsByTagName('a')[0].attributes['title'];
      String pageUrl = body[i].getElementsByTagName('a')[0].attributes['href'];
      String imageUrl = body[i].getElementsByTagName('img')[0].attributes['src'];

      animals.add(new AnimalCategory(pageUrl, imageUrl, title));
    }

    return animals;
  } else throw Exception('Проверьте интернет соединение');
}