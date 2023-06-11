import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'detail_route.dart';
import 'package:flutter_tts/flutter_tts.dart';

class PageViewWidget extends StatefulWidget {
  const PageViewWidget(
      {required this.images, required this.index, required this.tts, Key? key})
      : super(key: key);

  final List<AssetEntity> images;
  final int index;
  final FlutterTts tts;

  @override
  _PageViewWidgetState createState() => _PageViewWidgetState();
}

class _PageViewWidgetState extends State<PageViewWidget> {
  int currentPage = 0;
  List<String> pageName = ["First Page", "Second Page", "Third Page"];

  PageController controller =
      PageController(initialPage: 0, viewportFraction: 1);

  @override
  void initState() {
    controller = PageController(initialPage: widget.index, viewportFraction: 1);
    currentPage = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: PageView.builder(
        controller: controller,
        onPageChanged: (value) {
          setState(() {
            currentPage = value;
          });
        },
        itemCount: pageName.length,
        itemBuilder: (context, index) {
          return Container(
            color: Colors.blue.withOpacity(index * 0.1),
            child: DetailRoute(image: widget.images[index], tts: widget.tts),
            // child: Center(
            //   child: Text(
            //     widget.images[index].id,
            //     style: TextStyle(fontSize: 50),
            //   ),
            // ),
          );
        },
      ),
    );
  }
}
