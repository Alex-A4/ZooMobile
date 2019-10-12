import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:zoo_mobile/models/animals.dart';
import 'package:zoo_mobile/models/animals_category_data.dart';
import 'package:zoo_mobile/widgets/downloading_widgets.dart';
import 'package:http/http.dart' as http;

class AnimalsViewer extends StatefulWidget {
  final AnimalCategory _category;

  AnimalsViewer(this._category);

  @override
  _AnimalsViewerState createState() => _AnimalsViewerState(_category);
}

class _AnimalsViewerState extends State<AnimalsViewer>
    with TickerProviderStateMixin {
  final AnimalCategory _category;

  Future<Animal> _data;

  TabController _controller;


  @override
  void initState() {
    super.initState();
    _data = fetchData(_category.pageUrl);
  }

  _AnimalsViewerState(this._category);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _controller = TabController(
              length: (snapshot.data as Animal).tabElements.length,
              vsync: this,
              initialIndex: 0,
            );

            return getListView(snapshot.data);
          } else if (snapshot.hasError) {
            print('${snapshot.error}');
            showToast('Проверьте интернет соединение');

            // Close news if there is no connectivity
            Navigator.pop(context);
          }

          return getProgressBar();
        },
      ),
    );
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget getListView(Animal animal) {
    return CustomScrollView(
      key: PageStorageKey("AnimalList${_category.title}"),
      slivers: <Widget>[
        //AppBar
        SliverAppBar(
          pinned: true,
          elevation: 3,
          title: Text(
            _category.title,
          ),
          expandedHeight: 250,
          //HEADER IMAGE
          flexibleSpace: FlexibleSpaceBar(
            background: Image.network(
              _category.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),

        //Content
        SliverList(
          delegate: SliverChildListDelegate(
            <Widget>[
              // TEXT OF ANIMAL
              Container(
                padding: EdgeInsets.only(left: 16.0, right: 16.0),
                child: Text(
                  animal.description,
                  softWrap: true,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17.0,
                  ),
                ),
              ),

              // CONTENT OF ANIMAL
              SizedBox(
                height: 30,
              ),

              TabBar(
                unselectedLabelColor: Colors.green[400],
                labelColor: Colors.green[800],
                indicator: BoxDecoration(
                    border: Border.all(
                        color: Colors.yellow[600],
                        width: 2.0
                    ),
                    borderRadius: BorderRadius.circular(10.0)
                ),
                controller: _controller,
                tabs: animal.tabElements.keys.map((key) =>
                new Tab(
                  child: Text(
                    key,
                    style: TextStyle(
                        fontSize: 18.0
                    ),
                  ),
                )
                ).toList(),
                isScrollable: true,
              ),

              Divider(),

              //TabView which contains interesting facts about animal
              Container(
                height: 200,
                padding: EdgeInsets.only(
                    left: 16.0, right: 16.0, top: 8.0, bottom: 16.0),
                child: TabBarView(
                  controller: _controller,
                  children: animal.tabElements.values.map((value) =>
                  //Show dialog with full text by clicking on text
                  GestureDetector(
                      onTap: () {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(
                                  animal.tabElements.keys.toList()[_controller
                                      .index],
                                ),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0)
                                ),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: <Widget>[
                                      Text(
                                        value,

                                        style: TextStyle(
                                            fontSize: 17.0,
                                            color: Colors.black
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text(
                                      'Супер!',
                                      style: TextStyle(
                                          fontSize: 17.0,
                                          color: Colors.black
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  )
                                ],
                              );
                            }
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            value,
                            maxLines: 7,
                            style: TextStyle(
                                fontSize: 17.0,
                                color: Colors.black
                            ),
                            overflow: TextOverflow.clip,
                          ),
                          Text(
                            'Читать далее...',
                            style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 17.0
                            ),
                          )
                        ],
                      )
                  )
                  ).toList(),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  //Downloading data
  Future<Animal> fetchData(String pageUrl) async {
    final response = await http.get(pageUrl);

    if (response.statusCode == 200) {
      Map<String, String> tabItems = new Map();
      var textAreas = parse(response.body).getElementsByClassName(
          'element-textarea');
      var itemRows = parse(response.body).getElementsByClassName('item-tabs')[0]
          .getElementsByTagName('ul')[0].getElementsByTagName('li');
      var zooPlacement = parse(response.body).getElementsByClassName(
          'element-text');

      //Is there right tagging
      int isRight = 1;
      String description = '';
      description += '${zooPlacement[0].text.trim()
          .replaceAll('<\/?[\w]+>', '')}\n';


      if (textAreas.length == itemRows.length)
        isRight = 0;

      //If there is right tagging then build description by the textArea
      //else by the zooPlacement
      if (isRight == 1) {
        var descrP = textAreas[0].getElementsByTagName('p');

        //Building description
        //Replace all tags to empty string
        for (int i = 0; i < descrP.length; i++)
          description += '${descrP[i].text.replaceAll('<\/?[\w]+>', '')}\n';
      } else {
        for (int i = 1; i < zooPlacement.length; i++)
          description += '${zooPlacement[i].text.trim()
              .replaceAll('<\/?[\w]+>', '')}\n';
      }

      //Building items of tab
      for (int i = 0; i < itemRows.length; i++) {
        String tabName = itemRows[i].getElementsByTagName('a')[0].text.trim();
        String tabText = textAreas[i + isRight].getElementsByTagName('p')[0]
            .text.trim();

        tabItems['$tabName'] = tabText;
      }

      return new Animal(description.trim(), tabItems);
    } else
      throw Exception('Проверьте интернет соединение');
  }
}