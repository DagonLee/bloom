import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import '../sqlhelper.dart';
import 'detail_route.dart';
import 'package:flutter_tts/flutter_tts.dart';

class PageViewWidget extends StatefulWidget {
  const PageViewWidget(
      {required this.images, required this.index, required this.tts, Key? key, required this.desc})
      : super(key: key);
  final String desc;
  final List<AssetEntity> images;
  final int index;
  final FlutterTts tts;

  @override
  _PageViewWidgetState createState() => _PageViewWidgetState();
}

class _PageViewWidgetState extends State<PageViewWidget> {
  int currentPage = 0;
  List<String> pageName = ["First Page", "Second Page", "Third Page"];
String desc ="";
  PageController controller =
      PageController(initialPage: 0, viewportFraction: 1);

  @override
  void initState() {
    controller = PageController(initialPage: widget.index, viewportFraction: 1);
    currentPage = widget.index;
    desc = widget.desc;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: PageView.builder (
        controller: controller,
        onPageChanged: (value) async {
          setState(() {
            currentPage = value;        
          });
          File? originFile = await widget.images[currentPage].originFile;
          String originPath = originFile!.path;
          String file_name = originPath.split("/").last;
          SQLHelper.getItem(file_name)
        .then((value) => {
          widget.tts.speak(value.first["imgDesc"]),
          desc = value.first["imgDesc"],
        });
  
        },
        itemCount: pageName.length,
        itemBuilder: (context, index) {
          return Container(
            color: Colors.blue.withOpacity(index * 0.1),
            child: DetailRoute(image: widget.images[index], tts: widget.tts, desc: desc,),
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
