import 'package:c_7_1/main.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

final dummyItems = [
  'https://cdn.pixabay.com/photo/2018/11/12/18/44/thanksgiving-3811492_1280.jpg',
  'https://cdn.pixabay.com/photo/2019/10/30/15/33/tajikistan-4589831_1280.jpg',
  'https://cdn.pixabay.com/photo/2019/11/25/16/15/safari-4652364_1280.jpg',
];

void main() => runApp(MyApp());

class page1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: <Widget>[_buildTop(), _buildMiddle(), _buildBottom()],
    );
  }

  Widget _buildTaxiMenu(String title, {bool invisible = false}) {
    return InkWell(
      onTap: () {
        print(title);
      },
      child: Opacity(
        opacity: invisible == true ? 0.0 : 1.0,
        child: Column(
          children: [Icon(Icons.local_taxi, size: 40), Text(title)],
        ),
      ),
    );
  }

  //상단
  Widget _buildTop() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTaxiMenu('택시1'),
            _buildTaxiMenu('택시2'),
            _buildTaxiMenu('택시3'),
            _buildTaxiMenu('택시4'),
          ],
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTaxiMenu('택시5'),
            _buildTaxiMenu('택시6'),
            _buildTaxiMenu('택시7'),
            _buildTaxiMenu('택시8'),
            Opacity(opacity: 0.5, child: _buildTaxiMenu('택시9')),
          ],
        ),
      ],
    );
  }

  Widget _buildMiddle() {
    return CarouselSlider(
      options: CarouselOptions(height: 150, autoPlay: true),
      items:
          dummyItems.map((url) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(url, fit: BoxFit.cover),
                  ),
                );
              },
            );
          }).toList(),
    );
  }

  Widget _buildBottom() {
    final items = List.generate(10, (i){
      return ListTile(
        leading: Icon(Icons.notifications_none),
        title: Text('[이벤트] 이것은 공지사항'),
      );
    });

    return ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: items,
    );
  }
}
