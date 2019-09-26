import 'package:flutter/material.dart';
import 'package:zoo_mobile/views/about_root.dart';
import 'package:zoo_mobile/views/manual_view.dart';
import 'package:zoo_mobile/views/news_root.dart';

/// Class which is equivalent to Android's ViewPager
/// Contains interaction pages
class _TabPager extends StatefulWidget {
  _TabPager({Key key}) : super(key: key);

  @override
  _TabPagerState createState() => _TabPagerState();
}

class _TabPagerState extends State<_TabPager> {
  int _currentPage = 0;

  // The list of pages with content
  final List<Widget> _pages = [NewsView(), AboutUsView(), ManualCategoryView()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages.elementAt(_currentPage),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.assignment), title: Text('Новости')),
          BottomNavigationBarItem(
              icon: Icon(Icons.people), title: Text('О нас')),
          BottomNavigationBarItem(
              icon: Icon(Icons.import_contacts), title: Text('Справочник')),
        ],
        fixedColor: Colors.green,
        currentIndex: _currentPage,
        onTap: _onPageChange,
      ),
    );
  }

  // Select the page at [index] position
  void _onPageChange(int index) {
    setState(() {
      _currentPage = index;
    });
  }
}

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      primaryColor: Colors.green[700],
      accentColor: Colors.yellow[400],
    ),
    title: 'Ярославский зоопарк',
    home: _TabPager(),
  ));
}
